<script setup lang="ts">
import { computed } from 'vue'
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
  Filler,
} from 'chart.js'
import type { ChartOptions } from 'chart.js'
import type { PopulationSnapshot } from '@/engine/types'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
  Filler,
)

const props = withDefaults(
  defineProps<{
    snapshots: PopulationSnapshot[]
    compact?: boolean
    title?: string
  }>(),
  { compact: false, title: 'Population (alle 10 Runden)' },
)

const chartData = computed(() => ({
  labels: props.snapshots.map((s) => (props.compact ? String(s.round) : `Runde ${s.round}`)),
  datasets: [
    {
      label: 'Knutt',
      data: props.snapshots.map((s) => s.knutt),
      borderColor: '#b83232',
      backgroundColor: 'rgba(184, 50, 50, 0.12)',
      tension: 0.25,
      fill: true,
      pointRadius: props.compact ? 1.5 : 3,
    },
    {
      label: 'Herzmuschel',
      data: props.snapshots.map((s) => s.muschel),
      borderColor: '#c9a227',
      backgroundColor: 'rgba(201, 162, 39, 0.12)',
      tension: 0.25,
      fill: true,
      pointRadius: props.compact ? 1.5 : 3,
    },
  ],
}))

const options = computed<ChartOptions<'line'>>(() => ({
  responsive: true,
  maintainAspectRatio: false,
  animation: props.compact ? false : undefined,
  plugins: {
    legend: { position: 'bottom', display: !props.compact },
    title: {
      display: !props.compact,
      text: props.title,
      color: '#3d3228',
      font: { size: 14, weight: 'bold' },
    },
    tooltip: { enabled: true },
  },
  scales: {
    x: {
      ticks: {
        font: { size: props.compact ? 9 : 11 },
        autoSkipPadding: 8,
      },
    },
    y: {
      beginAtZero: true,
      ticks: {
        stepSize: 1,
        font: { size: props.compact ? 9 : 11 },
      },
    },
  },
}))
</script>

<template>
  <div class="chart-wrap">
    <Line v-if="snapshots.length > 0" :data="chartData" :options="options" />
    <p v-else class="placeholder">Nach 10 Würfen erscheint hier das Diagramm.</p>
  </div>
</template>

<style scoped>
.chart-wrap {
  position: relative;
  height: 100%;
  width: 100%;
  min-height: 200px;
  max-width: 640px;
  margin: 0 auto;
}

.placeholder {
  text-align: center;
  color: #777;
  padding: 2rem 1rem;
  font-size: 0.95rem;
}
</style>
