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
            to="/wordlist"
          >
            単語リストへ
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
        重要単語が見つかりません
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

        <!-- 中文列 -->
        <template v-slot:item.chinese="{ item }">
          <span>{{ item.chinese }}</span>
        </template>

        <!-- 英语列 -->
        <template v-slot:item.english="{ item }">
          <span>{{ item.english }}</span>
        </template>

        <!-- ノート列 -->
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

        <!-- 操作列 -->
        <template v-slot:item.actions="{ item }">
          <div class="d-flex align-center" style="margin-left: -15px;">
            <v-btn
              icon="mdi-star"
              variant="text"
              size="small"
              color="warning"
              @click="toggleImportant(item)"
              class="mr-2"
            ></v-btn>
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
            class="cat-icon"
            variant="text" 
            @click="noteDialog = false"
          ></v-btn>
        </v-card-title>
        <v-card-text>
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

    <!-- 删除确认对话框 -->
    <v-dialog v-model="deleteDialog" max-width="400px">
      <v-card>
        <v-card-title class="text-h5">
          確認
          <v-spacer></v-spacer>
          <v-btn 
            icon="mdi-close" 
            variant="text" 
            @click="deleteDialog = false"
          ></v-btn>
        </v-card-title>
        <v-card-text>
          選択した単語を重要単語から削除しますか？
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="error"
            variant="text"
            @click="deleteSelectedWords"
          >
            削除
          </v-btn>
          <v-btn
            color="primary"
            variant="text"
            @click="deleteDialog = false"
          >
            キャンセル
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

export default {
  name: 'Important',
  data: () => ({
    lessonRange: {
      start: '1',
      end: '31'
    },
    itemsPerPage: 10,
    noteDialog: false,
    deleteDialog: false,
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
        title: '　　　 日本語',
        key: 'japanese',
        sortable: true,
        width: '30%'
      },
      {
        title: '中国語',
        key: 'chinese',
        sortable: true,
        width: '20%'
      },
      {
        title: '英語',
        key: 'english',
        sortable: true,
        width: '20%'
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
    expandedNotes: {},
    searchText: ''
  }),
  computed: {
    filteredWords() {
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
  },
  methods: {
    // 获取重要单词列表
    async fetchWords() {
      this.loading = true
      this.error = null
      try {
        const userStr = localStorage.getItem('user')
        if (!userStr) {
          this.error = 'ログインしてください'
          return
        }

        const user = JSON.parse(userStr)
        if (!user.userId) {
          this.error = 'ユーザー情報が不完全です。再度ログインしてください'
          return
        }

        const response = await wordService.getImportantWords(user.userId)
        if (response && response.data && response.data.code === 200) {
          this.words = response.data.data
          
          // 使用批量API获取笔记数据
          if (this.words.length > 0) {
            const wordIds = this.words.map(word => word.wordId !== undefined ? word.wordId : word.id)
            
            try {
              // 首先尝试批量获取笔记
              const batchNotes = await wordService.getBatchNotes(wordIds, user.userId)
              
              // 将笔记数据合并到单词数据中
              for (const word of this.words) {
                const wid = word.wordId !== undefined ? word.wordId : word.id
                word.note = batchNotes[wid] || ''
              }
            } catch (batchError) {
              // 如果批量API失败，回退到单个请求
              const isDev = import.meta.env.DEV
              if (isDev) {
                console.warn('批量获取笔记失败，回退到单个请求:', batchError)
              }
              
              // 分批处理，避免过多并发请求
              const batchSize = 5
              for (let i = 0; i < this.words.length; i += batchSize) {
                const batch = this.words.slice(i, i + batchSize)
                await Promise.all(batch.map(async (word) => {
                  const wid = word.wordId !== undefined ? word.wordId : word.id
                  try {
                    const noteRes = await wordService.getNoteByWordId(wid, user.userId)
                    if (noteRes.data && noteRes.data.code === 200) {
                      word.note = noteRes.data.data || ''
                    } else {
                      word.note = ''
                    }
                  } catch {
                    word.note = ''
                  }
                }))
              }
            }
          }
        } else {
          this.words = []
        }
      } catch (error) {
        this.error = error.response?.data?.message || '重要単語の取得に失敗しました'
        this.words = []
      } finally {
        this.loading = false
      }
    },

    // 播放日语发音
    async playAudio(word) {
      try {
        const utterance = new SpeechSynthesisUtterance(word.japanese)
        utterance.lang = 'ja-JP'
        utterance.rate = 1.0
        utterance.pitch = 1.0
        
        await new Promise((resolve, reject) => {
          utterance.onend = resolve
          utterance.onerror = reject
          window.speechSynthesis.speak(utterance)
        })
      } catch (error) {
        this.showSnackbar('音声の再生に失敗しました。ブラウザの設定を確認してください。', 'error')
      }
    },

    // 切换重要标记
    async toggleImportant(item) {
      try {
        // 只允许移除重点
        const userStr = localStorage.getItem('user')
        if (!userStr) {
          this.showSnackbar('ログインしてください', 'error')
          return
        }
        const user = JSON.parse(userStr)
        if (!user.userId) {
          this.showSnackbar('ユーザー情報が不完全です。再度ログインしてください', 'error')
          return
        }
        const requestBody = {
          userId: user.userId,
          wordId: item.wordId !== undefined ? item.wordId : item.id
        }
        const res = await wordService.deleteFromImportantWords(requestBody)
        if (res.data && res.data.code === 200) {
          this.showSnackbar('重要単語から削除しました', 'success')
          await this.fetchWords();
        } else {
          this.showSnackbar('削除に失敗しました', 'error')
        }
      } catch (error) {
        this.showSnackbar('操作に失敗しました', 'error')
      }
    },

    // 打开笔记对话框
    openNoteDialog(item) {
      this.currentItem = item
      this.currentNote = item.note || ''
      this.noteDialog = true
    },

    // 保存笔记
    async saveNote() {
      if (this.currentItem) {
        try {
          const userStr = localStorage.getItem('user')
          if (!userStr) {
            this.showSnackbar('ログインしてください', 'error')
            return
          }
          const user = JSON.parse(userStr)
          if (!user.userId) {
            this.showSnackbar('ユーザー情報が不完全です。再度ログインしてください', 'error')
            return
          }

          const noteDTO = {
            wordId: Number(this.currentItem.wordId || this.currentItem.id),
            memo: this.currentNote
          }
          const res = await wordService.saveNote(noteDTO, user.userId)
          if (res.data && res.data.code === 200) {
            this.currentItem.note = this.currentNote
            this.showSnackbar('ノートを保存しました', 'success')
          } else {
            this.showSnackbar('ノートの保存に失敗しました', 'error')
          }
        } catch (error) {
          console.error('保存笔记失败:', error)
          this.showSnackbar('ノートの保存に失敗しました', 'error')
        }
      }
      this.noteDialog = false
    },

    // 显示所有课程
    showAllLessons() {
      this.lessonRange = {
        start: '1',
        end: '31'
      }
    },

    // 切换笔记展开/收起
    toggleNoteExpand(item) {
      const key = item.wordId !== undefined ? item.wordId : item.id;
      this.expandedNotes[key] = !this.expandedNotes[key];
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