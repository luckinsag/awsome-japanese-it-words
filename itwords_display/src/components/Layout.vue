<template>
  <v-app>
    <BouncyBubbles v-if="isAuthPage" />
    <v-navigation-drawer
      v-if="isLoggedIn"
      v-model="drawer"
      app
      :rail="rail"
      permanent
      color="white"
      @mouseenter="rail = false"
      @mouseleave="rail = true"
    >
      <div class="user-profile pa-4">
        <div class="d-flex flex-column align-center">
          <v-avatar
            :size="rail ? 40 : 64"
            color="primary"
            class="mb-2"
            @click="openAvatarDialog"
            style="cursor: pointer"
          >
            <v-img v-if="currentAvatar" :src="currentAvatar" cover></v-img>
            <v-icon v-else :size="rail ? 20 : 32" color="white">mdi-account</v-icon>
          </v-avatar>
          <span v-if="!rail" class="text-subtitle-1">{{ username }}</span>
        </div>
      </div>

      <v-divider></v-divider>

      <v-list class="mt-4">
        <v-list-item
          v-for="item in menuItems"
          :key="item.title"
          :to="item.path"
          link
          class="nav-item"
          :exact="item.path === '/'"
        >
          <div class="d-flex align-center">
            <v-icon class="mr-6">{{ item.icon }}</v-icon>
            <span v-if="!rail">{{ item.title }}</span>
          </div>
        </v-list-item>
      </v-list>

      <template v-slot:append>
        <div v-if="!rail" class="pa-4 text-center">
          <span class="text-caption text-medium-emphasis">Version 3.0.0</span>
        </div>
      </template>
    </v-navigation-drawer>

    <!-- 头像选择对话框 -->
    <v-dialog v-model="avatarDialog" max-width="500px">
      <v-card>
        <v-card-title class="text-h5">
          プロフィール画像を選択
          <v-spacer></v-spacer>
          <v-btn icon="mdi-close" variant="text" @click="avatarDialog = false"></v-btn>
        </v-card-title>
        <v-card-text>
          <div class="avatar-grid">
            <v-avatar
              v-for="(avatar, index) in avatars"
              :key="index"
              :color="currentAvatar === avatar ? 'primary' : 'grey'"
              size="64"
              class="ma-2"
              @click="selectAvatar(avatar)"
              style="cursor: pointer"
            >
              <v-img :src="avatar" cover></v-img>
            </v-avatar>
          </div>
        </v-card-text>
      </v-card>
    </v-dialog>

    <v-app-bar
      v-if="isLoggedIn"
      app
      color="white"
      elevation="1"
    >
      <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>
      <v-toolbar-title>IT Words Learning</v-toolbar-title>
      
      <v-spacer></v-spacer>
      
      <div class="d-flex align-center mr-8">
        <v-btn
          color="error"
          variant="outlined"
          @click="logout"
        >
          ログアウト
        </v-btn>
      </div>
    </v-app-bar>

    <v-main>
      <v-container fluid class="pa-4">
        <router-view></router-view>
      </v-container>
    </v-main>

  </v-app>
</template>

<script>
import { useUserStore } from '@/store/user'; // 导入 Pinia store 的具名导出 useUserStore
import { storeToRefs } from 'pinia'; // 导入 storeToRefs
import BouncyBubbles from './BouncyBubbles.vue'

export default {
  name: 'Layout',
  components: {
    BouncyBubbles
  },
  // 新增 setup 选项来集成 Pinia Store
  setup() {
    const userStore = useUserStore(); // 获取 Pinia store 实例

    // 使用 storeToRefs 来解构 store 的 state，并保持响应式
    // 这样 username 和 isLoggedIn 就可以直接在模板和 Options API 中作为 this.username 访问
    const { username, isLoggedIn } = storeToRefs(userStore);

    return {
      // 暴露这些响应式引用给 Options API 和模板
      username,
      isLoggedIn,
      // 暴露整个 userStore 实例，以便在 methods 中调用 actions
      userStore
    };
  },
  data: () => ({
    drawer: true,
    rail: true,
    search: '',
    avatarDialog: false,
    currentAvatar: localStorage.getItem('userAvatar') || null,
    avatars: [
      '/avatars/1.jpg',      // 鼠
      '/avatars/2.jpg',      // 牛
      '/avatars/3.jpg',      // 虎
      '/avatars/4.jpg',      // 兔
      '/avatars/5.jpg',      // 龙
      '/avatars/6.jpg',      // 蛇
      '/avatars/7.jpg',      // 马
      '/avatars/8.jpg',      // 羊
      '/avatars/9.jpg',      // 猴
      '/avatars/10.jpg',     // 鸡
      '/avatars/11.jpg',     // 狗
      '/avatars/12.jpg'      // 猪
    ],
    menuItems: [
      {
        title: 'ホームページ',
        icon: 'mdi-home',
        path: '/'
      },
      {
        title: '単語学習',
        icon: 'mdi-book-open-page-variant',
        path: '/study'
      },
      {
        title: '単語リスト',
        icon: 'mdi-list-box',
        path: '/wordlist'
      },
      
   
      {
        title: '重要単語',
        icon: 'mdi-star',
        path: '/important'
      },
      {
        title: 'テスト',
        icon: 'mdi-pencil',
        path: '/test'
      },
      {
                      title: 'ミス単語',
        icon: 'mdi-close-circle',
        path: '/mistakes'
      },
      {
        title: 'データ分析',
        icon: 'mdi-chart-areaspline-variant',
        path: '/analysis'
      }
    ]
  }),
  computed: {
    // ⚠️ 移除这里对 isLoggedIn 的计算属性，因为它现在由 setup 暴露
    // isLoggedIn() {
    //   return !!this.userStore.isLoggedIn; // 或者直接用 setup 暴露的 isLoggedIn
    // },
    // ⚠️ 移除这里对 username 的计算属性，因为它现在由 setup 暴露
    // username() {
    //   return this.userStore.username || 'ユーザー名';
    // }
    isTestPage() {
      return this.$route.path === '/test'
    },
    isSettingsPage() {
      return this.$route.path === '/settings'
    },
    isAuthPage() {
      return this.$route.path === '/login' || this.$route.path === '/register'
    },
  },
  watch: {
    search(newValue) {
      // TODO: 実装検索機能
      console.log('Search:', newValue)
    }
  },
  methods: {
    logout() {
      // 通过 setup 暴露的 userStore 实例调用 clearUser action
      this.userStore.clearUser();
      // 因为 clearUser 已经处理了 localStorage.removeItem('user')，所以这里可以移除
      // localStorage.removeItem('user'); 

      this.$router.push('/login');
      // 重新加载页面可能不是必须的，因为 Pinia 状态和路由守卫会处理登录状态变化
      // setTimeout(() => { window.location.reload() }, 100);
    },
    openAvatarDialog() {
      this.avatarDialog = true
    },
    selectAvatar(avatar) {
      this.currentAvatar = avatar
      localStorage.setItem('userAvatar', avatar)
      this.avatarDialog = false
    }
  }
}
</script>


<style scoped>
/* 容器背景颜色 */
.v-main {
  background-color: rgb(239, 239, 239);
}

.nav-item {
  padding: 0 16px;
  margin-bottom: 5px;
}

.nav-item .v-icon {
  font-size: 24px;
}

.nav-item span {
  font-size: 14px;
  white-space: nowrap;
}

.user-profile {
  min-height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 当抽屉收起时调整头像区域高度 */
.v-navigation-drawer--rail .user-profile {
  min-height: 80px;
}

.avatar-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  justify-items: center;
  padding: 16px;
}

.v-avatar {
  transition: transform 0.2s;
  border: 2px solid transparent;
}

.v-avatar:hover {
  transform: scale(1.1);
}

.v-avatar[color="primary"] {
  border-color: rgb(var(--v-theme-primary));
}

.v-footer {
  background-color: rgba(255, 255, 255, 0.8) !important;
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}

.v-navigation-drawer :deep(.v-list) {
  flex-grow: 1;
}
</style> 