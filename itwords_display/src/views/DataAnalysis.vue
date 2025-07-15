<template>
  <div class="analysis-container">
    <v-card class="mb-4">
      <v-card-title class="text-h5 mb-4">データ分析</v-card-title>

      <v-card-text>
        <div class="mb-6">
          <div class="text-subtitle-1 mb-2">テスト成績推移</div>
          <div v-if="!loading" class="chart-container">
            <v-chart class="chart" :option="chartOption" autoresize />
          </div>
          <v-progress-circular
            v-else
            indeterminate
            color="primary"
          ></v-progress-circular>
        </div>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import { useUserStore } from '@/store/user'
import { storeToRefs } from 'pinia'
import wordService from '@/api/wordService'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  GridComponent,
  ToolboxComponent,
  DataZoomComponent
} from 'echarts/components'
import VChart from 'vue-echarts'

// 注册 ECharts 组件
use([
  CanvasRenderer,
  LineChart,
  TitleComponent,
  TooltipComponent,
  GridComponent,
  ToolboxComponent,
  DataZoomComponent
])

export default {
  name: 'DataAnalysis',
  components: {
    VChart
  },
  setup() {
    const userStore = useUserStore()
    const { userId } = storeToRefs(userStore)
    return {
      userId
    }
  },
  data: () => ({
    loading: false,
    error: null,
    testScores: []
  }),
  computed: {
    chartOption() {
      // 按时间排序
      const sortedScores = [...this.testScores].sort((a, b) => 
        new Date(a.testTime) - new Date(b.testTime)
      )

      return {
        title: {
          text: 'テスト成績推移',
          left: 'center'
        },
        tooltip: {
          trigger: 'axis',
          formatter: (params) => {
            const data = params[0]
            return `第${data.dataIndex + 1}回テスト<br/>
                    日付: ${this.formatDate(sortedScores[data.dataIndex].testTime)}<br/>
                    点数: ${data.value}点`
          }
        },
        xAxis: {
          type: 'category',
          name: 'テスト回数',
          data: sortedScores.map((_, index) => `第${index + 1}回`),
          axisLabel: {
            interval: 0
          }
        },
        yAxis: {
          type: 'value',
          name: '点数',
          min: 0,
          max: 100
        },
        series: [
          {
            name: 'テスト成績',
            type: 'line',
            data: sortedScores.map(score => score.score),
            markPoint: {
              data: [
                { type: 'max', name: '最高点' },
                { type: 'min', name: '最低点' }
              ]
            },
            markLine: {
              data: [
                { type: 'average', name: '平均点' }
              ]
            }
          }
        ],
        toolbox: {
          feature: {
            saveAsImage: {},
            dataZoom: {
              yAxisIndex: 'none'
            },
            restore: {}
          }
        },
        dataZoom: [
          {
            type: 'slider',
            show: true,
            xAxisIndex: [0],
            start: 0,
            end: 100
          }
        ]
      }
    }
  },
  methods: {
    async fetchTestScores() {
      this.loading = true
      this.error = null
      try {
        const response = await wordService.getTestScores(this.userId)
        if (response && response.data) {
          this.testScores = response.data
        } else {
          this.testScores = []
        }
      } catch (error) {
        console.error('获取考试成绩失败:', error)
        this.error = error.response?.data?.message || '成績の取得に失敗しました'
        this.testScores = []
      } finally {
        this.loading = false
      }
    },
    formatDate(dateString) {
      if (!dateString) return ''
      
      try {
        console.log('格式化时间，原始数据:', dateString, '类型:', typeof dateString)
        
        let date
        
        // 如果已经是Date对象，直接使用
        if (dateString instanceof Date) {
          date = dateString
        } else if (typeof dateString === 'string') {
          // 处理字符串格式的时间
          if (dateString.includes(' ')) {
            // 格式: "2025-01-15 14:30:25"
            const [datePart, timePart] = dateString.split(' ')
            const [year, month, day] = datePart.split('-')
            const [hours, minutes, seconds] = timePart.split(':')
            date = new Date(year, month - 1, day, hours, minutes, seconds)
          } else {
            // 其他格式，直接解析
            date = new Date(dateString)
          }
        } else {
          // 尝试直接转换为Date对象
          date = new Date(dateString)
        }
        
        // 检查日期是否有效
        if (isNaN(date.getTime())) {
          console.warn('无效的日期格式:', dateString)
          return dateString // 返回原始字符串
        }
        
        console.log('转换后的Date对象:', date)
        
        // 使用 toLocaleString 格式化时间
        const formattedDate = date.toLocaleString('ja-JP', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit',
          hour12: false, // 使用24小时制
          timeZone: 'Asia/Tokyo' // 明确指定时区
        })
        
        console.log('格式化后的时间:', formattedDate)
        return formattedDate
        
      } catch (error) {
        console.error('时间格式化错误:', error, '原始数据:', dateString)
        return dateString // 返回原始字符串
      }
    }
  },
  created() {
    this.fetchTestScores()
  }
}
</script>

<style scoped>
.analysis-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.chart-container {
  width: 100%;
  height: 400px;
}

.chart {
  width: 100%;
  height: 100%;
}
</style> 