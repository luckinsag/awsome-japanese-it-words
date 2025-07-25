import axios from 'axios'

// 创建 axios 实例
const api = axios.create({
  baseURL: '/api', // 使用相对路径，与wordService保持一致
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 只在开发环境中启用详细日志
const isDev = import.meta.env.DEV

// 添加请求拦截器
api.interceptors.request.use(
  config => {
    if (isDev) {
      // 打印完整的请求URL和配置
      const fullUrl = `${config.baseURL}${config.url}`
      console.log('Request URL:', fullUrl)
      console.log('Request Config:', {
        url: config.url,
        baseURL: config.baseURL,
        method: config.method,
        data: config.data,
        headers: config.headers
      })
    }
    return config
  },
  error => {
    console.error('Request Error:', error)
    return Promise.reject(error)
  }
)

// 添加响应拦截器
api.interceptors.response.use(
  response => {
    if (isDev) {
      console.log('Response:', {
        status: response.status,
        data: response.data,
        headers: response.headers,
        config: {
          url: response.config.url,
          baseURL: response.config.baseURL
        }
      })
    }
    return response
  },
  error => {
    console.error('Response Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
      config: {
        url: error.config?.url,
        baseURL: error.config?.baseURL,
        method: error.config?.method,
        data: error.config?.data
      }
    })
    return Promise.reject(error)
  }
)

export default {
  // 用户登录
  login(username, password) {
    return api.post('/auth/login', {
      username,
      password
    })
  },

  // 用户注册
  register(userData) {
    return api.post('/auth/register', userData)
  }
} 