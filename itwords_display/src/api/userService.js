import axios from 'axios'

// 创建 axios 实例
const api = axios.create({
  baseURL: 'http://localhost:8080', // 直接使用完整的后端地址
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 添加请求拦截器
api.interceptors.request.use(
  config => {
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
    console.log('Response:', {
      status: response.status,
      data: response.data,
      headers: response.headers,
      config: {
        url: response.config.url,
        baseURL: response.config.baseURL
      }
    })
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
    return api.post('/api/auth/login', {
      username,
      password
    })
  },

  // 用户注册
  register(userData) {
    return api.post('/api/auth/register', userData)
  }
} 