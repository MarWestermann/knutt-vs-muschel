<script setup lang="ts">
defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  close: []
}>()
</script>

<template>
  <Teleport to="body">
    <div v-if="open" class="backdrop" role="dialog" aria-modal="true" aria-labelledby="rules-title" @click.self="emit('close')">
      <div class="modal">
        <header class="hdr">
          <h2 id="rules-title">Spielregeln</h2>
          <button type="button" class="close" aria-label="Schließen" @click="emit('close')">×</button>
        </header>
        <div class="body">
          <p>
            Zwei Spieler:innen wechseln sich ab. Der erste Würfel bestimmt die <strong>Spalte (x)</strong>, der zweite die
            <strong>Zeile (y)</strong> (jeweils 1–6).
          </p>
          <p><strong>Knutt (Jäger):</strong> frisst Herzmuschel auf dem Ziel und vermehrt sich (zweites Knutt auf freies
            Nachbarfeld). Leeres Feld oder Knutt auf dem Ziel: ein Knutt verhungert.</p>
          <p><strong>Herzmuschel (Beute):</strong> vermehrt sich auf leeres Ziel oder Nachbarfeld. Auf Knutt: wird gefressen,
            neues Knutt auf Nachbarfeld.</p>
          <p><strong>Volles Spielfeld:</strong> Herzmuschel-Vermehrung ist 5 Züge lang eingeschränkt (Pause-Zähler).</p>
          <p><strong>Einwanderung:</strong> Ist eine Art ausgestorben, erscheint wieder ein Plättchen auf einem freien Feld.</p>
          <p><strong>Ende:</strong> Nach 20 Protokollpunkten (je alle 10 Runden) oder spätestens nach 200 Würfen.</p>
          <p class="more">Ausführliche Fassung: <code>docs/spielregeln.md</code> im Repository.</p>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
  padding: 1rem;
}

.modal {
  background: #fffdf8;
  border-radius: 16px;
  max-width: 36rem;
  width: 100%;
  max-height: min(85vh, 540px);
  overflow: auto;
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.2);
}

.hdr {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  position: sticky;
  top: 0;
  background: #fffdf8;
}

.hdr h2 {
  margin: 0;
  font-size: 1.2rem;
  color: #3d3228;
}

.close {
  border: none;
  background: transparent;
  font-size: 1.75rem;
  line-height: 1;
  cursor: pointer;
  color: #666;
  padding: 0.25rem 0.5rem;
}

.body {
  padding: 1rem 1.25rem 1.5rem;
  color: #333;
  line-height: 1.5;
  font-size: 0.95rem;
}

.body p {
  margin: 0 0 0.75rem;
}

.more {
  font-size: 0.85rem;
  color: #666;
}
</style>
