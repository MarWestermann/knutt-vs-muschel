# Deployment – Web

Dieses Verzeichnis enthält den Docker-Container und die Kubernetes-Manifeste für die
Web-Version von **Knutt vs. Herzmuschel**.

- Host: `knutt-vs-muschel.isagtestcloud.intersales.de`
- Namespace: `knutt-vs-muschel`
- Ingress-Class: `nginx`
- TLS: cert-manager (`ClusterIssuer: letsencrypt-prod`) – ggf. anpassen

## Container bauen

Aus dem Verzeichnis `web/`:

```bash
docker build -t ghcr.io/intersales/knutt-vs-muschel-web:latest .
docker run --rm -p 8080:8080 ghcr.io/intersales/knutt-vs-muschel-web:latest
# Aufruf: http://localhost:8080
```

Empfohlen: Tag mit Git-SHA bauen und pushen.

```bash
TAG=$(git rev-parse --short HEAD)
docker build -t ghcr.io/intersales/knutt-vs-muschel-web:$TAG .
docker push ghcr.io/intersales/knutt-vs-muschel-web:$TAG
```

## In Kubernetes deployen

Aus dem Verzeichnis `web/deploy/k8s/`:

```bash
# Image-Tag setzen (statt latest)
kustomize edit set image ghcr.io/intersales/knutt-vs-muschel-web=ghcr.io/intersales/knutt-vs-muschel-web:$TAG

# Manifeste anwenden
kubectl apply -k .
```

Oder ohne Kustomize direkt:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml -f service.yaml -f ingress.yaml
```

Status prüfen:

```bash
kubectl -n knutt-vs-muschel get pods,svc,ingress
kubectl -n knutt-vs-muschel rollout status deploy/knutt-vs-muschel-web
```

## Hinweise

- Der Container läuft als nicht-root auf Port `8080`, mit read-only Root-FS.
- nginx liefert die SPA aus, fällt für unbekannte Pfade auf `index.html` zurück
  und stellt unter `/healthz` einen einfachen Health-Endpoint bereit (für Probes).
- Wenn das Cluster keinen cert-manager hat, die `cert-manager.io/*` Annotation
  entfernen und das TLS-Secret manuell anlegen.
- Falls ein anderer Ingress-Controller (z. B. Traefik) verwendet wird, die
  `ingressClassName` und Annotations entsprechend anpassen.
