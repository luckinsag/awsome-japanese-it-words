<template>
  <div class="register-container">
    <v-card class="register-card" elevation="2">
      <v-card-title class="text-center text-h4 mb-4">
        新規登録
      </v-card-title>
      <v-card-text>
        <v-form @submit.prevent="handleRegister">
          <v-text-field
            v-model="username"
            label="ユーザー名"
            prepend-inner-icon="mdi-account"
            variant="outlined"
            class="mb-4"
          ></v-text-field>
          <v-text-field
            v-model="password"
            label="パスワード"
            prepend-inner-icon="mdi-lock"
            :type="showPassword ? 'text' : 'password'"
            :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="showPassword = !showPassword"
            variant="outlined"
            class="mb-4"
          ></v-text-field>
          <v-text-field
            v-model="confirmPassword"
            label="パスワード（確認）"
            prepend-inner-icon="mdi-lock-check"
            :type="showConfirmPassword ? 'text' : 'password'"
            :append-inner-icon="showConfirmPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="showConfirmPassword = !showConfirmPassword"
            variant="outlined"
            class="mb-6"
          ></v-text-field>
          <v-alert
            v-if="error"
            type="error"
            class="mb-4"
            dense
          >
            {{ error }}
          </v-alert>
          <v-btn
            color="primary"
            block
            type="submit"
            :loading="loading"
            class="mb-4"
          >
          新規登録
          </v-btn>
          <div class="text-center">
            <router-link to="/login" class="text-decoration-none">
              すでにアカウントをお持ちの方はこちら
            </router-link>
          </div>
        </v-form>
      </v-card-text>
    </v-card>
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
import userService from '@/api/userService'

export default {
  name: 'Register',
  data: () => ({
    username: '',
    password: '',
    confirmPassword: '',
    showPassword: false,
    showConfirmPassword: false,
    loading: false,
    error: null,
    snackbar: {
      show: false,
      text: '',
      color: 'error'
    }
  }),
  methods: {
    async handleRegister() {
      if (!this.username || !this.password) {
        this.snackbar = {
          show: true,
          text: 'ユーザー名とパスワードを入力してください',
          color: 'error'
        }
        return;
      }
      if (this.password !== this.confirmPassword) {
        this.error = 'パスワードが一致しません'
        return
      }

      this.loading = true
      this.error = null
      try {
        const response = await userService.register({
          username: this.username,
          password: this.password,
          fontSize: 'm', // 默认字体大小
          backgroundColor: 'w' // 默认背景颜色
        })
        if (response.data.code === 200) {
          // 注册成功，跳转到登录页
          this.$router.push('/login')
        } else {
          this.error = response.data.message || '登録に失敗しました'
        }
      } catch (error) {
        console.error('Register error:', error)
        if (error.response) {
          // 服务器返回了错误响应
          this.error = error.response.data?.message || 'サーバーエラーが発生しました'
        } else if (error.request) {
          // 请求已发送但没有收到响应
          this.error = 'サーバーに接続できません。後でもう一度お試しください。'
        } else {
          // 请求配置出错
          this.error = 'リクエストエラーが発生しました'
        }
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.register-container {
  height: 100vh;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  background-color: #f5f5f5;
  padding-top: 8vh;
}

.register-card {
  width: 480px;
  padding: 2.5rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
  background-color: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  position: relative;
}

:deep(.v-card-title) {
  font-size: 2rem !important;
  font-weight: 500 !important;
  color: #1a1a1a;
}

:deep(.v-text-field) {
  margin-bottom: 1.5rem;
}

:deep(.v-btn) {
  height: 48px !important;
  font-size: 1.1rem !important;
  text-transform: none !important;
}

:deep(.v-btn--block) {
  margin-bottom: 1.5rem;
}

:deep(a) {
  color: #1976d2;
  font-size: 0.95rem;
}
</style> 