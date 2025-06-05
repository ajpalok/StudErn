// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import ToastController from "./toast_controller"
import MobileMenuController from "./mobile_menu_controller"


application.register("toast", ToastController)
application.register("mobile-menu", MobileMenuController)