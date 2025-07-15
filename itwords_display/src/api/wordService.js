import axios from 'axios'

// 创建 axios 实例
const api = axios.create({
  baseURL: '/api', // 使用相对路径，让 Vite 代理处理
  timeout: 15000,  // 增加超时时间到 15 秒
  headers: {
    'Content-Type': 'application/json'
  }
})

// 添加请求拦截器
api.interceptors.request.use(
  config => {
    console.log('Request URL:', config.url);
    console.log('Request Method:', config.method);
    console.log('Request Headers:', config.headers);
    console.log('Request Data:', config.data);
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
    console.log('Response Status:', response.status);
    console.log('Response Data:', response.data);
    return response
  },
  error => {
    console.error('Response Error Status:', error.response?.status);
    console.error('Response Error Data:', error.response?.data);
    return Promise.reject(error)
  }
)

export default {
  // 获取所有单词
  getAllWords() {
    return api.post('/words/all')
  },

  // 获取按课程分类的单词
  getWordsByCategories(startLesson, endLesson) {
    // 生成课程列表，格式为 "Lesson X"
    const categories = []
    for (let i = parseInt(startLesson); i <= parseInt(endLesson); i++) {
      categories.push(`Lesson ${i}`)
    }
    
    console.log('Sending categories:', categories)
    // 发送 JSON 数组
    return api.post('/words/byCategories', JSON.stringify(categories))
  },

  // 批量获取笔记内容
  getNotesByWordIds(wordIds, userId) {
    return api.post('/notes/batch', {
      wordIds,
      userId
    })
  },

  // 添加重点单词
  addToImportantWords(userNoteDTO) {
    // 确保请求体格式正确
    const requestBody = {
      userId: Number(userNoteDTO.userId),  // 确保是数字类型
      wordId: Number(userNoteDTO.wordId),  // 确保是数字类型
      memo: null  // 添加重点单词时不需要笔记内容
    }
    console.log('添加重点单词请求体:', requestBody);
    return api.post('/userNotes/addto-important-wordlist', requestBody)
  },

  // 删除重点单词
  deleteFromImportantWords(deleteDTO) {
    return api.post('/userNotes/delete-important-words', deleteDTO)
  },

  // 查询用户所有重点单词
  getImportantWords(userId) {
    return api.post('/userNotes/show-important-wordlist', { userId })
  },

  // 获取单词笔记内容
  getNoteByWordId(wordId, userId) {
    return api.post('/userNotes/get-comments', { wordId }, { headers: { userId } })
  },

  // 保存或更新笔记内容
  saveNote(noteDTO, userId) {
    return api.put('/userNotes/save-comments', noteDTO, { headers: { userId } })
  },

  // 保存考试记录
  saveUserTest(userTestDTO) {
    // 确保请求体格式正确
    const requestBody = {
      userId: Number(userTestDTO.userId),  // 确保是数字类型
      endedAt: userTestDTO.endedAt,        // 修正字段名：endAt -> endedAt
      score: Number(userTestDTO.score)     // 确保是数字类型
    }
    console.log('保存考试记录请求体:', requestBody);
    return api.post('/userTest/add', requestBody)
  },

  // 添加错题
  insertWrong(userWrongDTO) {
    // 确保请求体格式正确，匹配 UserWrongDTO 结构
    const requestBody = {
      sessionId: Number(userWrongDTO.sessionId),  // 考试编号
      wordId: Number(userWrongDTO.wordId),        // 单词ID
      userId: Number(userWrongDTO.userId)         // 用户ID
    }
    console.log('添加错题请求体:', requestBody);
    return api.post('/userWrong/add', requestBody)
  },

  // 删除错题
  deleteWrong(userWrongDeleteDTO) {
    // 确保请求体格式正确，匹配 UserWrongDeleteDTO 结构
    const requestBody = {
      userId: Number(userWrongDeleteDTO.userId),    // 用户ID
      wordId: Number(userWrongDeleteDTO.wordId)     // 单词ID
    }
    console.log('删除错题请求体:', requestBody);
    return api.post('/userWrong/delete', requestBody)
  },

  // 获取错题列表
  listWrong(userWrongSelectDTO) {
    // 确保请求体格式正确，匹配 UserWrongSelectDTO 结构
    const requestBody = {
      userId: Number(userWrongSelectDTO.userId)  // 用户ID
    }
    console.log('获取错题列表请求体:', requestBody);
    return api.post('/userWrong/list', requestBody)
  },

  // 获取用户考试成绩列表
  getTestScores(userId) {
    console.log('获取考试成绩列表，用户ID:', userId);
    return api.get(`/testSessions/user/${userId}`)
  }
} 