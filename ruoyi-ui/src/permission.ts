import { to as tos } from 'await-to-js';
import router from './router';
import NProgress from 'nprogress';
import 'nprogress/nprogress.css';
import { getToken } from '@/utils/auth';
import { isHttp, isPathMatch } from '@/utils/validate';
import { isRelogin } from '@/utils/request';
import { useUserStore } from '@/store/modules/user';
import { useSettingsStore } from '@/store/modules/settings';
import { usePermissionStore, loadRouters } from '@/store/modules/permission';
import { ElMessage } from 'element-plus/es';

// 首屏守卫需要等待 getInfo/getRouters 接口返回，默认的 trickle 推进极慢(0.02/200ms)
// 会导致进度条长时间停留在低位看起来像卡死，这里调快推进节奏
NProgress.configure({ showSpinner: false, minimum: 0.15, trickleSpeed: 150, trickleRate: 0.04 });
const whiteList = ['/login', '/register', '/social-callback', '/register*', '/register/*'];

const isWhiteList = (path: string) => {
  return whiteList.some((pattern) => isPathMatch(pattern, path));
};

router.beforeEach(async (to, from, next) => {
  NProgress.start();
  if (getToken()) {
    to.meta.title && useSettingsStore().setTitle(to.meta.title as string);
    /* has token*/
    if (to.path === '/login') {
      next({ path: '/' });
      NProgress.done();
    } else if (isWhiteList(to.path)) {
      next();
    } else {
      if (useUserStore().roles.length === 0) {
        isRelogin.show = true;
        // 并发拉取用户信息与菜单路由，减少进入主页面的串行等待
        const infoPromise = useUserStore().getInfo();
        const routersPromise = loadRouters();
        routersPromise.catch(() => {}); // getInfo失败时避免getRouters的拒绝无人处理
        // 判断当前用户是否已拉取完user_info信息
        const [err] = await tos(infoPromise);
        if (err) {
          // logout接口失败不应阻塞跳转 避免守卫抛异常导致进度条卡死
          try {
            await useUserStore().logout();
          } catch {
            /* ignore */
          }
          ElMessage.error(err);
          next({ path: '/' });
        } else {
          const [routersErr, routersRes] = await tos(routersPromise);
          if (routersErr) {
            ElMessage.error(routersErr);
            next({ path: '/' });
          } else {
            isRelogin.show = false;
            const accessRoutes = await usePermissionStore().generateRoutes(routersRes);
            // 根据roles权限生成可访问的路由表
            accessRoutes.forEach((route) => {
              if (!isHttp(route.path)) {
                router.addRoute(route); // 动态添加可访问路由表
              }
            });
            // @ts-expect-error hack方法 确保addRoutes已完成
            next({ path: to.path, replace: true, params: to.params, query: to.query, hash: to.hash, name: to.name as string }); // hack方法 确保addRoutes已完成
          }
        }
      } else {
        next();
      }
    }
  } else {
    // 没有token
    if (isWhiteList(to.path)) {
      // 在免登录白名单，直接进入
      next();
    } else {
      const redirect = encodeURIComponent(to.fullPath || '/');
      next(`/login?redirect=${redirect}`); // 否则全部重定向到登录页
      NProgress.done();
    }
  }
});

router.afterEach(() => {
  NProgress.done();
});
