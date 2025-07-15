// src/store/user.js (或 src/stores/user.js，根据你的实际路径)
import { defineStore } from 'pinia' // 导入 defineStore

// 定义并导出 Pinia Store
export const useUserStore = defineStore('user', { // ⚠️ 关键：使用 defineStore 定义
  state: () => ({
    // 你的响应式状态
    username: '',
    userId: null, // 将 userId 初始值设为 null 或其他适当的默认值
    email: '',    // 如果你的用户还有 email 字段，也在这里定义
    isLoggedIn: false // 添加一个登录状态
  }),
  actions: {
    // 设置用户状态
    setUser(user) {
      this.username = user.username
      this.userId = user.userId
      this.email = user.email || ''; // 假设 user 对象可能包含 email
      this.isLoggedIn = true;
      localStorage.setItem('user', JSON.stringify(user)) // 保存到 localStorage
    },

    // 清除用户状态
    clearUser() {
      this.username = ''
      this.userId = null
      this.email = ''
      this.isLoggedIn = false;
      localStorage.removeItem('user') // 从 localStorage 移除
    },

    // 从 localStorage 中恢复用户状态 (可以在应用启动时调用)
    initUserState() {
      const userStr = localStorage.getItem('user')
      if (userStr) {
        try {
          const user = JSON.parse(userStr)
          // 确保 user 对象有对应的属性
          this.username = user.username || '';
          this.userId = user.userId || null;
          this.email = user.email || '';
          this.isLoggedIn = true; // 如果从 localStorage 恢复，则认为是已登录
        } catch (e) {
          console.error('Failed to parse user data from localStorage:', e);
          this.clearUser(); // 解析失败则清除
        }
      }
    }
  },
  // 可以添加 getters，例如
  getters: {
    isAuthenticated: (state) => state.isLoggedIn
  }
})

// ⚠️ 注意：旧的 initUserState() 调用不能放在这里，因为它会过早执行。
// 你可以在 main.js 中应用初始化后调用 store.initUserState()