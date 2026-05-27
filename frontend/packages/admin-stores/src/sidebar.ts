import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useSidebarStore = defineStore('admin-sidebar', () => {
  const collapsed = ref(false)
  const activeMenu = ref('')

  function toggle() {
    collapsed.value = !collapsed.value
  }

  function setActiveMenu(menu: string) {
    activeMenu.value = menu
  }

  function expand() {
    collapsed.value = false
  }

  function collapse() {
    collapsed.value = true
  }

  return {
    collapsed,
    activeMenu,
    toggle,
    setActiveMenu,
    expand,
    collapse,
  }
})
