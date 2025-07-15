<template>
  <div>
    <!-- 顶部操作栏 -->
    <v-card class="mb-4">
      <v-card-text>
        <div class="d-flex align-center">
          <!-- 搜索框 -->
          <v-text-field
            v-model="searchText"
            prepend-inner-icon="mdi-magnify"
            placeholder="単語を入力..."
            hide-details
            density="compact"
            style="max-width: 500px; background: #f5f5f5; border-radius: 8px; margin-right: 24px;"
            class="search-field"
          ></v-text-field>
          <div class="d-flex align-center mr-4">
            
            <v-select
              v-model="lessonRange.start"
              :items="lessonOptions"
              label=""
              density="compact"
              hide-details
              style="width: 150px;"
              class="mr-4"
            ></v-select>
            <span class="mr-4">～</span>
            
            <v-select
              v-model="lessonRange.end"
              :items="lessonOptions"
              label=""
              density="compact"
              hide-details
              style="width: 150px;"
            ></v-select>
            
          </div>
          
          <v-btn
            color="primary"
            variant="text"
            class="mr-4"
            @click="showAllLessons"
          >
            全部
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/study"
          >
            単語学習へ
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/test"
          >
            テストへ
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/important"
          >
            重要単語へ
          </v-btn>

          <v-btn
            color="secondary"
            variant="text"
            class="mr-4"
            to="/mistakes"
          >
                                  ミス単語へ
          </v-btn>
        </div>
      </v-card-text>
    </v-card>

    <!-- 单词列表 -->
    <v-card>
      <v-card-text v-if="loading">
        読み込み中...
      </v-card-text>
      <v-card-text v-else-if="error">
        {{ error }}
      </v-card-text>
      <v-card-text v-else-if="!words.length">
        単語が見つかりません
      </v-card-text>
      <v-data-table
        v-else
        :headers="headers"
        :items="filteredWords"
        :items-per-page="itemsPerPage"
        class="elevation-1"
      >
        <!-- 日语列 -->
        <template v-slot:item.japanese="{ item }">
          <div class="d-flex align-center" style="padding-left: 45px;">
            <span class="text-h6">{{ item.japanese }}</span>
            <v-btn
              icon="mdi-volume-high"
              variant="text"
              size="small"
              class="ml-2"
              @click="playAudio(item)"
            ></v-btn>
          </div>
        </template>

        <!-- 英语列 -->
        <template v-slot:item.english="{ item }">
          <span>{{ item.english }}</span>
        </template>

        <!-- 笔记列 -->
        <template v-slot:item.note="{ item }">
          <span v-if="!item.note">-</span>
          <span v-else>
            <span v-if="!expandedNotes[item.wordId || item.id]">
              {{ item.note.length > 20 ? (item.note.slice(0, 20) + '...') : item.note }}
              <span v-if="item.note.length > 20" class="note-expand" @click.stop="toggleNoteExpand(item)">[展開]</span>
            </span>
            <span v-else>
              {{ item.note }}
              <span class="note-expand" @click.stop="toggleNoteExpand(item)">[折りたたむ]</span>
            </span>
          </span>
        </template>

        <!-- 中文列 -->
        <template v-slot:item.chinese="{ item }">
          <span>{{ item.chinese }}</span>
        </template>

        <!-- 操作列 -->
        <template v-slot:item.actions="{ item }">
          <div class="d-flex align-center" style="margin-left: -15px;">
            <v-btn
              icon="mdi-star"
              variant="text"
              size="small"
              :color="item.isImportant ? 'warning' : ''"
              @click="toggleImportant(item)"
              class="mr-2"
            ></v-btn>
            <!-- 有笔记的时候空心笔团变成实心笔，warningse -->
            <v-btn
              
              icon="mdi-lead-pencil"
              variant="text"
              size="small"
              :color="item.note ? 'warning' : ''"
              @click="openNoteDialog(item)"
            ></v-btn>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- 笔记对话框 -->
    <v-dialog v-model="noteDialog" max-width="500px">
      <v-card>
        <v-card-title class="text-h5">
          ノート
          <v-spacer></v-spacer>
          <v-btn 
            icon="mdi-cat" 
            variant="text" 
            @click="noteDialog = false"
            size="large"
            class="cat-icon"
          ></v-btn>
        </v-card-title>
        <v-card-text>
          <div style="color: #888; font-size: 13px; margin-bottom: 4px;">
            ※ノートを保存すると、この単語は自動的に重要単語としてマークされます。
          </div>
          <v-textarea
            v-model="currentNote"
            label="ノートを書く"
            rows="4"
            auto-grow
            hide-details
          ></v-textarea>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            variant="text"
            @click="saveNote"
          >
            保存
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 提示信息 -->
    <v-snackbar
      v-model="snackbar.show"
      :color="snackbar.color"
      :timeout="3000"
    >
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>

<script>
import wordService from '@/api/wordService'
import { useUserStore } from '@/store/user'

export default {
  name: 'WordList',
  setup() {
    const userStore = useUserStore();
    return {
      userStore
    };
  },
  data: () => ({
    lessonRange: {
      start: '1',
      end: '31'
    },
    itemsPerPage: 10,
    noteDialog: false,
    currentNote: '',
    currentItem: null,
    snackbar: {
      show: false,
      text: '',
      color: 'info'
    },
    lessonOptions: Array.from({ length: 31 }, (_, i) => ({
      title: `Lesson ${i + 1}`,
      value: String(i + 1)
    })),
    headers: [
      {
        title: '　　　日本語',
        key: 'japanese',
        sortable: true,
        width: '30%'
      },
      {
        title: '中国語',
        key: 'chinese',
        sortable: true,
        width: '15%'
      },
      {
        title: '英語',
        key: 'english',
        sortable: true,
        width: '15%'
      },
      {
        title: 'ノート',
        key: 'note',
        sortable: false,
        width: '20%'
      },
      {
        title: '操作',
        key: 'actions',
        sortable: false,
        width: '10%',
        align: 'start'
      }
    ],
    words: [],
    loading: false,
    error: null,
    importantWordIds: [],
    expandedNotes: {},
    searchText: '',
    notesCache: new Map(),
    isLoadingNotes: false,
    // 添加一个Set来跟踪哪些单词有笔记
    wordsWithNotes: new Set(),
  }),
  computed: {
    filteredWords() {
      const isDev = import.meta.env.DEV
      if (isDev) {
        console.log('filteredWords 计算，searchText:', this.searchText);
      }
      if (!this.searchText) return this.words;
      const keyword = this.searchText.trim().toLowerCase();
      return this.words.filter(word => {
        return (
          (word.japanese && word.japanese.toLowerCase().includes(keyword)) ||
          (word.chinese && word.chinese.toLowerCase().includes(keyword)) ||
          (word.english && word.english.toLowerCase().includes(keyword)) ||
          (word.note && word.note.toLowerCase().includes(keyword))
        );
      });
    }
  },
  watch: {
    lessonRange: {
      handler(newRange) {
        this.fetchWords()
      },
      deep: true
    }
  },
  created() {
    this.fetchWords()
    this.fetchImportantWords()
  },
  methods: {
    // 获取单词列表
    async fetchWords() {
      this.loading = true
      this.error = null
      try {
        const isDev = import.meta.env.DEV
        if (isDev) {
          console.log('Fetching words with range:', this.lessonRange)
        }
        let response
        // 如果选择了全部课程，使用 getAllWords
        if (this.lessonRange.start === '1' && this.lessonRange.end === '31') {
          response = await wordService.getAllWords()
        } else {
          // 否则使用 getWordsByCategories
          response = await wordService.getWordsByCategories(
            this.lessonRange.start,
            this.lessonRange.end
          )
        }
        if (isDev) {
          console.log('Received response:', response)
        }
        if (response && response.data && response.data.data) {
          this.words = response.data.data
          // 标记重点单词
          await this.fetchImportantWords()
          
          // 同步重点标记状态
          this.words.forEach(word => {
            const wid = word.wordId !== undefined ? word.wordId : word.id
            word.isImportant = this.importantWordIds.includes(wid)
          })
          
          // 只为重点单词异步加载笔记内容
          this.loadNotesForImportantWords()
          
          if (isDev) {
            console.log('Updated words:', this.words)
          }
        } else {
          console.error('Invalid response format:', response)
          this.words = []
        }
      } catch (error) {
        this.error = error.response?.data?.message || '単語リストの取得に失敗しました'
        console.error('Error fetching words:', error)
        if (error.response) {
          console.error('Error response:', error.response)
        }
        this.words = []
      } finally {
        this.loading = false
      }
    },

    // 获取用户所有重点单词
    async fetchImportantWords() {
      const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
      if (!userId) return
      try {
        const res = await wordService.getImportantWords(userId)
        if (res.data && res.data.data) {
          this.importantWordIds = res.data.data.map(item => item.wordId)
        } else {
          this.importantWordIds = []
        }
      } catch {
        this.importantWordIds = []
      }
    },

    // 播放日语发音
    async playAudio(word) {
      const isDev = import.meta.env.DEV
      if (isDev) {
        console.log('Playing audio for:', word.japanese)
      }
      
      try {
        // 使用 Web Speech API
        const utterance = new SpeechSynthesisUtterance(word.japanese)
        utterance.lang = 'ja-JP'
        utterance.rate = 1.0 // 正常语速
        utterance.pitch = 1.0
        
        // 等待语音播放完成
        await new Promise((resolve, reject) => {
          utterance.onend = resolve
          utterance.onerror = reject
          window.speechSynthesis.speak(utterance)
        })
        
        if (isDev) {
          console.log('Speech synthesis completed')
        }
      } catch (error) {
        console.error('Speech synthesis failed:', error)
        this.$nextTick(() => {
          this.$vuetify.snackbar = {
            show: true,
            text: '音声の再生に失敗しました。ブラウザの設定を確認してください。',
            color: 'error'
          }
        })
      }
    },

    // 切换重要标记
    async toggleImportant(item) {
      const isDev = import.meta.env.DEV
      if (isDev) {
        console.log('当前item:', item);
      }
      const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
      if (!userId) {
        this.showSnackbar('ログインしてください', 'error')
        return
      }
      if (!item.isImportant) {
        // 添加重点
        try {
          const requestBody = {
            userId: Number(userId),
            wordId: Number(item.wordId),
            memo: null
          }
          if (isDev) {
            console.log('添加重点单词请求体:', requestBody);
          }
          const res = await wordService.addToImportantWords(requestBody)
          if (res.data && res.data.code === 200) {
            item.isImportant = true
            this.importantWordIds.push(item.wordId)
            this.showSnackbar('重要単語に追加しました', 'success')
          } else {
            this.showSnackbar('追加に失敗しました', 'error')
          }
        } catch (error) {
          console.error('添加重点单词失败:', error);
          this.showSnackbar('追加に失敗しました', 'error')
        }
      } else {
        // 删除重点
        try {
          const requestBody = {
            userId: Number(userId),
            wordId: Number(item.wordId)
          }
          if (isDev) {
            console.log('删除重点单词请求体:', requestBody);
          }
          const res = await wordService.deleteFromImportantWords(requestBody)
          if (res.data && res.data.code === 200) {
            item.isImportant = false
            this.importantWordIds = this.importantWordIds.filter(id => id !== item.wordId)
            // 清除笔记缓存
            this.notesCache.delete(item.wordId)
            this.wordsWithNotes.delete(item.wordId)
            item.note = ''
            this.showSnackbar('重要単語から削除しました', 'success')
          } else {
            this.showSnackbar('削除に失敗しました', 'error')
          }
        } catch (error) {
          console.error('删除重点单词失败:', error);
          this.showSnackbar('削除に失敗しました', 'error')
        }
      }
    },

    // 打开笔记对话框
    async openNoteDialog(item) {
      this.currentItem = item
      this.currentNote = ''
      // 获取笔记内容
      try {
        const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
        const wordId = item.wordId !== undefined ? item.wordId : item.id
        const res = await wordService.getNoteByWordId(wordId, userId)
        if (res.data && res.data.code === 200) {
          this.currentNote = res.data.data || ''
        } else {
          this.currentNote = ''
        }
      } catch (error) {
        console.error('获取笔记失败:', error)
        this.currentNote = ''
      }
      this.noteDialog = true
    },

    // 只为重点单词异步加载笔记内容
    async loadNotesForImportantWords() {
      if (this.isLoadingNotes) return
      this.isLoadingNotes = true
      
      const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
      if (!userId) {
        this.isLoadingNotes = false
        return
      }

      // 只获取重点单词的笔记
      const importantWords = this.words.filter(word => {
        const wid = word.wordId !== undefined ? word.wordId : word.id
        return this.importantWordIds.includes(wid) && !this.notesCache.has(wid)
      })

      if (importantWords.length === 0) {
        // 如果所有重点单词的笔记都在缓存中，直接使用缓存
        this.words.forEach(word => {
          const wid = word.wordId !== undefined ? word.wordId : word.id
          if (this.importantWordIds.includes(wid)) {
            word.note = this.notesCache.get(wid) || ''
          } else {
            word.note = '' // 非重点单词不显示笔记
          }
        })
        this.isLoadingNotes = false
        return
      }

      try {
        // 使用批量API一次性获取所有重点单词的笔记
        const wordIds = importantWords.map(word => word.wordId !== undefined ? word.wordId : word.id)
        const batchRes = await wordService.getBatchNotes(wordIds, userId)
        
        if (batchRes.data && batchRes.data.code === 200) {
          const notesMap = batchRes.data.data || {}
          
          // 更新缓存和单词对象
          importantWords.forEach(word => {
            const wordId = word.wordId !== undefined ? word.wordId : word.id
            const note = notesMap[wordId] || ''
            this.notesCache.set(wordId, note)
            if (note) {
              this.wordsWithNotes.add(wordId)
            }
            word.note = note
          })
        }
      } catch (e) {
        // 如果批量API失败，回退到单个请求方式
        const isDev = import.meta.env.DEV
        if (isDev) {
          console.warn('批量获取笔记失败，回退到单个请求:', e)
        }
        
        // 分批加载笔记，每批5个（减少并发请求）
        const batchSize = 5
        for (let i = 0; i < importantWords.length; i += batchSize) {
          const batch = importantWords.slice(i, i + batchSize)
          const promises = batch.map(async (word) => {
            const wordId = word.wordId !== undefined ? word.wordId : word.id
            try {
              const noteRes = await wordService.getNoteByWordId(wordId, userId)
              if (noteRes.data && noteRes.data.code === 200) {
                const note = noteRes.data.data || ''
                this.notesCache.set(wordId, note)
                if (note) {
                  this.wordsWithNotes.add(wordId)
                }
                return { wordId, note }
              }
            } catch (e) {
              // 404错误不记录日志，这是正常的
              if (e.response?.status !== 404) {
                console.error(`获取笔记失败 wordId: ${wordId}`, e)
              }
            }
            return { wordId, note: '' }
          })
          
          const results = await Promise.all(promises)
          results.forEach(({ wordId, note }) => {
            const word = this.words.find(w => (w.wordId !== undefined ? w.wordId : w.id) === wordId)
            if (word) {
              word.note = note
            }
          })
        }
      } finally {
        this.isLoadingNotes = false
      }
    },

    // 保存笔记时更新缓存
    async saveNote() {
      if (!this.currentItem) return
      
      const memoContent = this.currentNote.trim()
      const userId = this.userStore.userId || (JSON.parse(localStorage.getItem('user')||'{}').userId)
      if (!userId) {
        this.showSnackbar('ログインしてください', 'error')
        return
      }

      try {
        // 如果不是重点，且有笔记内容，才自动标记为重点
        if (!this.currentItem.isImportant && memoContent && memoContent.trim()) {
          const importantRes = await wordService.addToImportantWords({
            userId: Number(userId),
            wordId: Number(this.currentItem.wordId),
            memo: null
          })
          if (importantRes.data && importantRes.data.code === 200) {
            this.currentItem.isImportant = true;
            if (!this.importantWordIds.includes(this.currentItem.wordId)) {
              this.importantWordIds.push(this.currentItem.wordId);
            }
          } else {
            this.showSnackbar('自動保存に失敗しました。ノートを保存できません', 'error')
            return
          }
        }
        const noteDTO = {
          wordId: Number(this.currentItem.wordId),
          memo: memoContent
        }
        const isDev = import.meta.env.DEV
        if (isDev) {
          console.log('保存笔记请求体:', noteDTO, 'userId:', userId)
        }
        const res = await wordService.saveNote(noteDTO, userId)
        if (res.data && res.data.code === 200) {
          this.currentItem.note = memoContent
          // 更新缓存
          this.notesCache.set(this.currentItem.wordId, memoContent)
          if (memoContent) {
            this.wordsWithNotes.add(this.currentItem.wordId)
          } else {
            this.wordsWithNotes.delete(this.currentItem.wordId)
          }
          this.showSnackbar('保存しました', 'success')
        } else {
          this.showSnackbar('保存に失敗しました', 'error')
        }
      } catch (error) {
        console.error('保存笔记失败:', error)
        this.showSnackbar('保存に失敗しました', 'error')
      }
      this.noteDialog = false
    },

    // 切换笔记展开/收起
    toggleNoteExpand(item) {
      const key = item.wordId !== undefined ? item.wordId : item.id;
      this.expandedNotes[key] = !this.expandedNotes[key];
    },

    // 显示所有课程
    showAllLessons() {
      this.lessonRange = {
        start: '1',
        end: '31'
      }
    },

    // 显示提示信息
    showSnackbar(text, color = 'info') {
      this.snackbar = {
        show: true,
        text,
        color
      }
    }
  }
}
</script>

<style scoped>
.v-data-table {
  background: white;
}

/* 搜索框样式 */
.search-field {
  transition: all 0.3s ease;
}

.search-field:hover {
  background: #eeeeee !important;
}

.search-field :deep(.v-field__input) {
  padding: 8px 16px;
  font-size: 14px;
}

.search-field :deep(.v-field__prepend-inner) {
  padding-inline-start: 8px;
  padding-inline-end: 8px;
}

.search-field :deep(.v-icon) {
  margin-left: 0px;
}

/* 笔记按钮样式 */
.v-btn.mr-2 {
  margin-right: 8px;
}

/* 猫图标样式 */
.cat-icon {
  transform: scale(1.5);
}

.cat-icon :deep(.v-icon) {
  font-size: 32px !important;
}

.note-expand {
  color: #1976d2;
  cursor: pointer;
  font-size: 12px;
  margin-left: 4px;
}

/* 优化表格中单词显示 */
.v-data-table :deep(.v-data-table__td) {
  padding: 12px 16px !important;
  vertical-align: middle !important;
}

/* 日语单词列样式优化 */
.v-data-table :deep(.v-data-table__td:first-child) {
  min-width: 200px;
}

.v-data-table :deep(.text-h6) {
  word-wrap: break-word;
  word-break: break-all;
  line-height: 1.4;
  max-width: 180px;
  white-space: normal;
}

/* 英语和中文列样式优化 */
.v-data-table :deep(.v-data-table__td:nth-child(2)),
.v-data-table :deep(.v-data-table__td:nth-child(3)) {
  word-wrap: break-word;
  word-break: break-word;
  line-height: 1.4;
  white-space: normal;
}

/* 笔记列样式优化 */
.v-data-table :deep(.v-data-table__td:nth-child(4)) {
  word-wrap: break-word;
  word-break: break-word;
  line-height: 1.4;
  white-space: normal;
  max-width: 200px;
}

/* 提高表格行高 */
.v-data-table :deep(.v-data-table__tr) {
  min-height: 60px;
}

/* 表头字体加大 */
.v-data-table :deep(.v-data-table__th) {
  font-size: 1.05rem !important;
  font-weight: 600 !important;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .v-data-table :deep(.text-h6) {
    font-size: 1.1rem !important;
    max-width: 120px;
  }
  
  .v-data-table :deep(.v-data-table__td) {
    padding: 8px 12px !important;
  }
}
</style> 