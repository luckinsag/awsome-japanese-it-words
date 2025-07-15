<template>
  <AuthLayout>
    <v-card class="login-card" elevation="2">
      <v-card-title class="text-center text-h4 mb-4">
        welcome
      </v-card-title>
      <v-card-text>
        <v-form @submit.prevent="handleLogin">
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
            ログイン
          </v-btn>
          <div class="text-center">
            <router-link to="/register" class="text-decoration-none">
              アカウントをお持ちでない方はこちら
            </router-link>
          </div>
        </v-form>
      </v-card-text>
    </v-card>
  </AuthLayout>
</template>

<script>
import userService from '@/api/userService'
import { useUserStore } from '@/store/user'
import AuthLayout from '@/components/AuthLayout.vue'

export default {
  name: 'Login',
  components: {
    AuthLayout
  },
  data: () => ({
    username: '',
    password: '',
    showPassword: false,
    loading: false,
    error: null
  }),
  setup() {
    const userStore = useUserStore()
    return { userStore }
  },
  methods: {
    async handleLogin() {
      if (!this.username || !this.password) {
        this.error = 'ユーザー名とパスワードを入力してください'
        return
      }

      this.loading = true
      this.error = null
      try {
        console.log('Attempting login with:', { username: this.username })
        const response = await userService.login(this.username, this.password)
        console.log('Login response:', response)
        
        if (response.data.code === 200) {
          console.log('Login successful, user data:', response.data.data)
          console.log('User data type:', typeof response.data.data)
          console.log('User data keys:', Object.keys(response.data.data))
          // 登录成功，保存用户信息到状态管理
          this.userStore.setUser(response.data.data)
          // 跳转到首页，去掉强制刷新
          this.$router.push('/')
        } else {
          console.error('Login failed:', response.data)
          this.error = response.data.message || 'ログインに失敗しました'
        }
      } catch (error) {
        console.error('Login error:', error)
        if (error.response) {
          // 服务器返回了错误响应
          console.error('Server error response:', error.response)
          this.error = error.response.data?.message || 'サーバーエラーが発生しました'
        } else if (error.request) {
          // 请求已发送但没有收到响应
          console.error('No response received:', error.request)
          this.error = 'サーバーに接続できません。後でもう一度お試しください。'
        } else {
          // 请求配置出错
          console.error('Request error:', error.message)
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
.login-card {
  width: 480px;
  padding: 2.5rem;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08) !important;
  background-color: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  position: relative;
  z-index: 1;
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