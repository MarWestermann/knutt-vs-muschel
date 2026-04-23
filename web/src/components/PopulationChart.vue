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

const props = defineProps<{
  snapshots: PopulationSnapshot[]
}>()

const chartData = computed(() => ({
  labels: props.snapshots.map((s) => `Runde ${s.round}`),
  datasets: [
    {
      label: 'Knutt',
      data: props.snapshots.map((s) => s.knutt),
      borderColor: '#b83232',
      backgroundColor: 'rgba(184, 50, 50, 0.12)',
      tension: 0.25,
      fill: true,
    },
    {
      label: 'Herzmuschel',
      data: props.snapshots.map((s) => s.muschel),
      borderColor: '#c9a227',
      backgroundColor: 'rgba(201, 162, 39, 0.12)',
      tension: 0.25,
      fill: true,
    },
  ],
}))

const options: ChartOptions<'line'> = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'bottom' },
    title: {
      display: true,
      text: 'Population (alle 10 Runden)',
      color: '#3d3228',
      font: { size: 14, weight: 'bold' },
    },
  },
  scales: {
    y: {
      beginAtZero: true,
      ticks: { stepSize: 1 },
    },
  },
}
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
  height: 260px;
  width: 100%;
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
