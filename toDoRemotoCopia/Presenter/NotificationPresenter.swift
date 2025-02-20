import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()
    }
    
    // Añadir este método para mostrar notificaciones cuando la app está activa
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Esto permite mostrar la notificación incluso con la app en primer plano
        completionHandler([.banner, .sound, .badge])
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error solicitando autorización: \(error.localizedDescription)")
            } else {
                print("Autorización de notificaciones: \(success ? "concedida" : "denegada")")
                // Verificar el estado actual
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    print("Estado actual de notificaciones:")
                    print("- Autorización: \(settings.authorizationStatus.rawValue)")
                    print("- Alertas: \(settings.alertSetting.rawValue)")
                    print("- Sonidos: \(settings.soundSetting.rawValue)")
                    print("- Badges: \(settings.badgeSetting.rawValue)")
                }
            }
        }
    }
    
    func scheduleNotification(for task: ToDoTaskItem) {
        guard let reminderDate = task.reminderDate else {
            print("Error: No hay fecha de recordatorio")
            return
        }
        
        // Verificar si la fecha es futura
        if reminderDate < Date() {
            print("Error: La fecha del recordatorio es en el pasado: \(reminderDate)")
            return
        }
        
        print("Programando notificación para: \(reminderDate)")
        
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio: \(task.title)"
        content.body = task.description.isEmpty ? "Tienes una tarea pendiente" : task.description
        content.sound = .default
        
        // Crear componentes de fecha más precisos
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminderDate)
        components.second = 0 // Asegurar que los segundos estén en 0
        
        print("Componentes de fecha programados: \(components)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Verificar la próxima fecha de disparo
        if let nextTriggerDate = trigger.nextTriggerDate() {
            print("Próxima fecha de disparo: \(nextTriggerDate)")
        }
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al programar notificación: \(error)")
            } else {
                print("Notificación programada con éxito")
                // Verificar inmediatamente que la notificación se agregó
                self.checkPendingNotifications()
            }
        }
        
        if let recurrence = task.recurrence {
            scheduleRecurringNotification(for: task, with: recurrence)
        }
    }
    
    private func scheduleRecurringNotification(for task: ToDoTaskItem, with recurrence: TaskRecurrence) {
        guard let reminderDate = task.reminderDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio recurrente: \(task.title)"
        content.body = task.description.isEmpty ? "Tienes una tarea pendiente" : task.description
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        
        switch recurrence {
        case .daily:
            // Componentes ya están correctos para diario
            break
        case .weekly:
            dateComponents.weekday = Calendar.current.component(.weekday, from: reminderDate)
        case .monthly:
            dateComponents.day = Calendar.current.component(.day, from: reminderDate)
        case .yearly:
            dateComponents.month = Calendar.current.component(.month, from: reminderDate)
            dateComponents.day = Calendar.current.component(.day, from: reminderDate)
        case .custom:
            return // Manejar caso personalizado si se implementa
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "\(task.id.uuidString)_recurring",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [taskId.uuidString, "\(taskId.uuidString)_recurring"]
        )
    }
    
    // Añade este método para pruebas
    func sendTestNotification() {
        print("Intentando enviar notificación de prueba...")
        let content = UNMutableNotificationContent()
        content.title = "Prueba de Notificación"
        content.body = "Esta es una notificación de prueba"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al enviar notificación de prueba: \(error)")
            } else {
                print("Notificación de prueba programada correctamente")
            }
        }
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("=== Notificaciones pendientes: \(requests.count) ===")
            for request in requests {
                print("ID: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("Título: \(request.content.title)")
                    print("Mensaje: \(request.content.body)")
                    print("Componentes: \(trigger.dateComponents)")
                    if let nextTriggerDate = trigger.nextTriggerDate() {
                        print("Próximo disparo: \(nextTriggerDate)")
                    }
                    print("---")
                }
            }
        }
    }
} 