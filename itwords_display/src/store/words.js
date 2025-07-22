import { defineStore } from 'pinia'
import wordService from '@/api/wordService'

export const useWordsStore = defineStore('words', {
  state: () => ({
    // 单词数据缓存
    wordsCache: new Map(),
    // 笔记缓存 - 使用普通对象来确保响应式
    notesCache: {},
    // 重要单词ID列表
    importantWordIds: [],
    // 有笔记的单词ID列表 - 使用数组来确保响应式
    wordsWithNotes: [],
    // 加载状态
    isLoading: false,
    // 错误信息
    error: null
  }),

  getters: {
    // 获取指定单词的笔记
    getNoteByWordId: (state) => (wordId) => {
      return state.notesCache[wordId] || ''
    },
    
    // 检查单词是否为重点单词
    isImportantWord: (state) => (wordId) => {
      return state.importantWordIds.includes(wordId)
    },
    
    // 检查单词是否有笔记
    hasNote: (state) => (wordId) => {
      return state.wordsWithNotes.includes(wordId)
    }
  },

  actions: {
    // 设置单词数据
    setWords(words) {
      words.forEach(word => {
        const wordId = word.wordId !== undefined ? word.wordId : word.id
        this.wordsCache.set(wordId, word)
      })
    },

    // 更新单词的笔记
    async updateWordNote(wordId, note, userId) {
      try {
        const noteDTO = {
          wordId: Number(wordId),
          memo: note
        }
        
        const res = await wordService.saveNote(noteDTO, userId)
        if (res.data && res.data.code === 200) {
                  // 更新缓存
        this.notesCache[wordId] = note
        
        if (note && note.trim()) {
          if (!this.wordsWithNotes.includes(wordId)) {
            this.wordsWithNotes.push(wordId)
          }
        } else {
          this.wordsWithNotes = this.wordsWithNotes.filter(id => id !== wordId)
        }
          
          // 更新单词缓存中的笔记
          const word = this.wordsCache.get(wordId)
          if (word) {
            word.note = note
          }
          
          return { success: true }
        } else {
          return { success: false, error: '保存に失敗しました' }
        }
      } catch (error) {
        console.error('保存笔记失败:', error)
        return { success: false, error: '保存に失敗しました' }
      }
    },

    // 添加单词到重要单词
    async addToImportant(wordId, userId) {
      try {
        const requestBody = {
          userId: Number(userId),
          wordId: Number(wordId),
          memo: null
        }
        
        const res = await wordService.addToImportantWords(requestBody)
        if (res.data && res.data.code === 200) {
          if (!this.importantWordIds.includes(wordId)) {
            this.importantWordIds.push(wordId)
          }
          
          // 更新单词缓存中的重点状态
          const word = this.wordsCache.get(wordId)
          if (word) {
            word.isImportant = true
          }
          
          return { success: true }
        } else {
          return { success: false, error: '追加に失敗しました' }
        }
      } catch (error) {
        console.error('添加重点单词失败:', error)
        return { success: false, error: '追加に失敗しました' }
      }
    },

    // 从重要单词中移除
    async removeFromImportant(wordId, userId) {
      try {
        const requestBody = {
          userId: Number(userId),
          wordId: Number(wordId)
        }
        
        const res = await wordService.deleteFromImportantWords(requestBody)
        if (res.data && res.data.code === 200) {
          this.importantWordIds = this.importantWordIds.filter(id => id !== wordId)
          
          // 清除笔记缓存
          delete this.notesCache[wordId]
          this.wordsWithNotes = this.wordsWithNotes.filter(id => id !== wordId)
          
          // 更新单词缓存中的重点状态和笔记
          const word = this.wordsCache.get(wordId)
          if (word) {
            word.isImportant = false
            word.note = ''
          }
          
          return { success: true }
        } else {
          return { success: false, error: '削除に失敗しました' }
        }
      } catch (error) {
        console.error('删除重点单词失败:', error)
        return { success: false, error: '削除に失敗しました' }
      }
    },

    // 加载重要单词列表
    async loadImportantWords(userId) {
      try {
        const res = await wordService.getImportantWords(userId)
        if (res.data && res.data.code === 200) {
          this.importantWordIds = res.data.data.map(item => item.wordId)
          return res.data.data
        } else {
          this.importantWordIds = []
          return []
        }
      } catch (error) {
        console.error('加载重要单词失败:', error)
        this.importantWordIds = []
        return []
      }
    },

    // 批量加载笔记
    async loadBatchNotes(wordIds, userId) {
      try {
        const batchRes = await wordService.getBatchNotes(wordIds, userId)
        if (batchRes.data && batchRes.data.code === 200) {
          const notesMap = batchRes.data.data || {}
          
          // 更新缓存
          Object.entries(notesMap).forEach(([wordId, note]) => {
            const numWordId = Number(wordId)
            this.notesCache[numWordId] = note
            if (note && note.trim()) {
              if (!this.wordsWithNotes.includes(numWordId)) {
                this.wordsWithNotes.push(numWordId)
              }
            }
          })
          
          return notesMap
        } else {
          return {}
        }
      } catch (error) {
        console.error('批量加载笔记失败:', error)
        return {}
      }
    },

    // 清除缓存
    clearCache() {
      this.wordsCache.clear()
      this.notesCache = {}
      this.importantWordIds = []
      this.wordsWithNotes = []
    }
  }
}) 