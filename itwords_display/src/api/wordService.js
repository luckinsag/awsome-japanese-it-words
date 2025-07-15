import axios from 'axios'

// 创建 axios 实例
const api = axios.create({
  baseURL: '/api', // 使用相对路径，让 Vite 代理处理
  timeout: 15000,  // 增加超时时间到 15 秒
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
      console.log('Request URL:', config.url);
      console.log('Request Method:', config.method);
      console.log('Request Headers:', config.headers);
      console.log('Request Data:', config.data);
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
      console.log('Response Status:', response.status);
      console.log('Response Data:', response.data);
    }
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
    
    if (isDev) {
      console.log('Sending categories:', categories)
    }
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

  // 添加到重点单词
  addToImportantWords(userNoteDTO) {
    // 确保请求体格式正确，匹配 UserNoteDTO 结构
    const requestBody = {
      userId: Number(userNoteDTO.userId),
      wordId: Number(userNoteDTO.wordId),
      memo: userNoteDTO.memo || null
    }
    if (isDev) {
      console.log('添加重点单词请求体:', requestBody);
    }
    return api.post('/userNotes/addto-important-wordlist', requestBody)
  },

  // 从重点单词删除
  deleteFromImportantWords(userNoteDeleteDTO) {
    // 确保请求体格式正确，匹配 UserNoteDeleteDTO 结构
    const requestBody = {
      userId: Number(userNoteDeleteDTO.userId),
      wordId: Number(userNoteDeleteDTO.wordId)
    }
    if (isDev) {
      console.log('删除重点单词请求体:', requestBody);
    }
    return api.post('/userNotes/delete-important-words', requestBody)
  },

  // 查询用户所有重点单词
  getImportantWords(userId) {
    return api.post('/userNotes/show-important-wordlist', { userId })
  },

  // 获取单词笔记内容
  getNoteByWordId(wordId, userId) {
    return api.post('/userNotes/get-comments', { wordId }, { headers: { userId } })
  },

  // 批量获取笔记内容
  getBatchNotes(wordIds, userId) {
    return api.post('/userNotes/batch-comments', { wordIds }, { headers: { userId } })
  },

  // 保存或更新笔记内容
  saveNote(noteDTO, userId) {
    return api.put('/userNotes/save-comments', noteDTO, { headers: { userId } })
  },

  // 保存用户考试记录
  saveUserTest(userTestDTO) {
    // 确保请求体格式正确，匹配 UserTestRecordDTO 结构
    const requestBody = {
      userId: Number(userTestDTO.userId),
      endedAt: userTestDTO.endedAt,
      score: Number(userTestDTO.score)
    }
    if (isDev) {
      console.log('保存考试记录请求体:', requestBody);
    }
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
    if (isDev) {
      console.log('添加错题请求体:', requestBody);
    }
    return api.post('/userWrong/add', requestBody)
  },

  // 删除错题
  deleteWrong(userWrongDeleteDTO) {
    // 确保请求体格式正确，匹配 UserWrongDeleteDTO 结构
    const requestBody = {
      userId: Number(userWrongDeleteDTO.userId),
      wordId: Number(userWrongDeleteDTO.wordId)
    }
    if (isDev) {
      console.log('删除错题请求体:', requestBody);
    }
    return api.post('/userWrong/delete', requestBody)
  },

  // 获取错题列表
  listWrong(userWrongSelectDTO) {
    // 确保请求体格式正确，匹配 UserWrongSelectDTO 结构
    const requestBody = {
      userId: Number(userWrongSelectDTO.userId)  // 用户ID
    }
    if (isDev) {
      console.log('获取错题列表请求体:', requestBody);
    }
    return api.post('/userWrong/list', requestBody)
  },

  // 获取用户考试成绩列表
  getTestScores(userId) {
    if (isDev) {
      console.log('获取考试成绩列表，用户ID:', userId);
    }
    return api.get(`/testSessions/user/${userId}`)
  }
} 