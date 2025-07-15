// main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// --- Pinia ---
import { createPinia } from 'pinia'
import { useUserStore } from '@/store/user' // 导入 useUserStore hook
const pinia = createPinia() // 创建 Pinia 实例

// Vuetify
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases, mdi } from 'vuetify/iconsets/mdi'
import '@mdi/font/css/materialdesignicons.css'

// Toast Plugin (如果已安装)
import { toast } from 'vue3-toastify';
import 'vue3-toastify/dist/index.css';

// Dialog Plugin (你的自定义实现)
const myDialogPlugin = {
  install(app) {
    app.config.globalProperties.$dialog = {
      confirm: ({ title, text, confirmText = 'OK', cancelText = 'Cancel' }) => {
        return new Promise((resolve) => {
          const result = window.confirm(`${title}\n\n${text}`);
          resolve(result);
        });
      }
    };
  }
};


const vuetify = createVuetify({
  // 1. 组件配置
  components,  // 导入所有 Vuetify 组件
  directives,  // 导入所有 Vuetify 指令

  // 2. 图标配置
  icons: {
    defaultSet: 'mdi',  // 设置默认图标集为 Material Design Icons
    aliases,           // 图标别名配置
    sets: {
      mdi,            // 使用 Material Design Icons 图标集
    },
  },

  // 3. 主题配置
  theme: {
    defaultTheme: 'light'  // 设置默认主题为亮色主题
  }
})

const app = createApp(App)

app.use(pinia) // ⚠️ 首先使用 Pinia

app.use(router)
app.use(vuetify)

// ⚠️ 全局挂载 Toast
app.config.globalProperties.$toast = toast;
// ⚠️ 使用自定义 Dialog 插件
app.use(myDialogPlugin);

// 添加全局路由守卫 (保持不变)
router.beforeEach((to, from, next) => {
  const publicPages = ['/login', '/register']
  // ⚠️ 使用 Pinia store 判断登录状态
  const userStore = useUserStore(); // 在路由守卫中获取 store 实例
  const isLoggedIn = userStore.isLoggedIn; // 从 store 获取登录状态

  // 如果 store 没有从 localStorage 初始化，则尝试加载
  if (!userStore.isLoggedIn && localStorage.getItem('user')) {
      userStore.initUserState(); // 尝试从 localStorage 加载
      // 重新检查登录状态，因为 initUserState 可能更新了它
      // isLoggedIn = userStore.isLoggedIn; // 理论上这里应该重新赋值，但路由守卫会重新触发
  }


  if (!isLoggedIn && !publicPages.includes(to.path)) {
    return next('/login')
  }
  if (isLoggedIn && publicPages.includes(to.path)) {
    return next('/')
  }
  next()
})

// ⚠️ 在应用程序挂载前调用 Pinia store 的初始化 action
app.mount('#app');
// 应用程序挂载后初始化用户状态 (确保 store 已经可用)
// 这里不能直接在 mount() 之前调用，因为 Pinia 实例需要先被 app.use(pinia) 关联
// 更安全的做法是在 store 自身定义一个 init 方法，并在主组件的 created/mounted 中调用一次
// 或者像上面的路由守卫一样，每次导航时检查

// 如果你希望在应用启动时就从 localStorage 加载用户数据，可以在 main.js 中这样做：
const userStore = useUserStore(); // 再次获取 store 实例，现在 Pinia 已经安装到 app
userStore.initUserState(); // 调用 store 中的 action 来初始化状态