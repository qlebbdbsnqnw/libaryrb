from telegram import (
    Update,
    InlineKeyboardButton,
    InlineKeyboardMarkup
)
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    CallbackQueryHandler,
    ConversationHandler,
    ContextTypes,
    filters
)

TOKEN = "PASTE_BOT_TOKEN"
ADMIN_ID = 0000000000  # <-- вставь свой ID

(
    MENU,
    AGREEMENT,
    NICK,
    TG,
    ROLE,
    EXPERIENCE,
    TIME,
    REASON,
    SUPPORT,
    DECLINE_REASON
) = range(10)

# ================== START MENU ==================
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = [
        [InlineKeyboardButton("📨 Подать заявку", callback_data="apply")],
        [InlineKeyboardButton("📜 Соглашение", callback_data="agreement")],
        [InlineKeyboardButton("🛠 Поддержка", callback_data="support")]
    ]

    await update.message.reply_text(
        "👋 Добро пожаловать в бота заявок клана!\n\n"
        "Выберите нужное действие:",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )
    return MENU

# ================== AGREEMENT ==================
AGREEMENT_TEXT = (
    "📜 *Соглашение*\n\n"
    "Вы будете согласны после отправленной заявки:\n\n"
    "1. Ваш Username будет отправлен создателю на рассмотрение\n"
    "2. Ваши данные (Username / Ник в Roblox / Звание) будут добавлены на сайте\n"
    "3. Мы не несем ответственности за Username, добавленные на сайте\n"
    "4. Вы будете состоять в клане, если вас примут\n"
    "5. Нужно строго выполнять приказы Командиров или Создателя\n"
    "6. Если вас изгоняют из клана — ответственность не несём\n"
    "7. Запрещено спамить заявками в боте\n"
    "8. Нарушение правил: 3 ошибки — мут 30 минут, повтор — изгнание\n"
    "9. Поддельные Username / Nickname запрещены и караются блокировкой\n\n"
    "_Если вы не согласны — вас просто не примут._"
)

async def agreement(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    keyboard = [[InlineKeyboardButton("✅ Согласиться", callback_data="agree")]]

    await query.message.reply_text(
        AGREEMENT_TEXT,
        reply_markup=InlineKeyboardMarkup(keyboard),
        parse_mode="Markdown"
    )
    return AGREEMENT

# ================== APPLY ==================
async def apply(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    await query.message.reply_text("Ваш ник в Roblox:")
    return NICK

async def nick(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["nick"] = update.message.text
    await update.message.reply_text("Ваш Username в Telegram:")
    return TG

async def tg(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["tg"] = update.message.text

    keyboard = [
        [
            InlineKeyboardButton("🛡 Охранник", callback_data="role_guard"),
            InlineKeyboardButton("⚔️ Спецназ", callback_data="role_spec")
        ]
    ]
    await update.message.reply_text("Кто вы?", reply_markup=InlineKeyboardMarkup(keyboard))
    return ROLE

async def role(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    context.user_data["role"] = "Охранник" if query.data == "role_guard" else "Спецназ"
    await query.message.reply_text("В чём ваш опыт?")
    return EXPERIENCE

async def experience(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["experience"] = update.message.text
    await update.message.reply_text("Сколько времени вы будете уделять клану?")
    return TIME

async def time(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["time"] = update.message.text
    await update.message.reply_text("Причина, по которой вы хотите вступить в клан?")
    return REASON

async def reason(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["reason"] = update.message.text

    text = (
        "📩 *Новая заявка*\n\n"
        f"Roblox: {context.user_data['nick']}\n"
        f"Telegram: {context.user_data['tg']}\n"
        f"Роль: {context.user_data['role']}\n"
        f"Опыт: {context.user_data['experience']}\n"
        f"Время: {context.user_data['time']}\n"
        f"Причина: {context.user_data['reason']}"
    )

    keyboard = [
        [
            InlineKeyboardButton("✅ Принять", callback_data=f"accept_{update.effective_user.id}"),
            InlineKeyboardButton("❌ Отклонить", callback_data=f"decline_{update.effective_user.id}")
        ]
    ]

    await context.bot.send_message(
        ADMIN_ID,
        text,
        reply_markup=InlineKeyboardMarkup(keyboard),
        parse_mode="Markdown"
    )

    await update.message.reply_text("✅ Ваша заявка отправлена")
    return ConversationHandler.END

# ================== SUPPORT ==================
async def support(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    await query.message.reply_text(
        "🛠 Поддержка\n\n"
        "Пожалуйста, напишите ваш вопрос.\n"
        "Мы ответим вам в ближайшее время 🙂"
    )
    return SUPPORT

async def support_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text

    msg = await context.bot.send_message(
        ADMIN_ID,
        f"📨 Сообщение в поддержку:\n\n{text}"
    )

    context.bot_data[msg.message_id] = update.effective_user.id
    await update.message.reply_text("✅ Ваше сообщение отправлено в поддержку")
    return ConversationHandler.END

async def admin_reply(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message.reply_to_message:
        return

    replied_id = update.message.reply_to_message.message_id
    if replied_id not in context.bot_data:
        return

    user_id = context.bot_data[replied_id]

    await context.bot.send_message(
        user_id,
        f"📩 Ответ от поддержки:\n{update.message.text}"
    )

# ================== ACCEPT / DECLINE ==================
async def accept(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    user_id = int(query.data.split("_")[1])

    await context.bot.send_message(
        user_id,
        "🎉 Вас приняли в клан, ожидайте пока вам напишут."
    )
    await query.edit_message_text("✅ Заявка принята")

async def decline(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    context.user_data["decline_user"] = int(query.data.split("_")[1])
    await query.message.reply_text("Напишите причину отклонения:")
    return DECLINE_REASON

async def decline_reason(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = context.user_data["decline_user"]
    await context.bot.send_message(
        user_id,
        f"❌ К сожалению, вашу заявку отклонили.\nПричина от создателя:\n{update.message.text}"
    )
    await update.message.reply_text("❌ Заявка отклонена")
    return ConversationHandler.END

# ================== MAIN ==================
def main():
    app = Application.builder().token(TOKEN).build()

    conv = ConversationHandler(
        entry_points=[CommandHandler("start", start)],
        states={
            MENU: [CallbackQueryHandler(apply, pattern="apply"),
                   CallbackQueryHandler(agreement, pattern="agreement"),
                   CallbackQueryHandler(support, pattern="support")],
            AGREEMENT: [CallbackQueryHandler(apply, pattern="agree")],
            NICK: [MessageHandler(filters.TEXT, nick)],
            TG: [MessageHandler(filters.TEXT, tg)],
            ROLE: [CallbackQueryHandler(role)],
            EXPERIENCE: [MessageHandler(filters.TEXT, experience)],
            TIME: [MessageHandler(filters.TEXT, time)],
            REASON: [MessageHandler(filters.TEXT, reason)],
            SUPPORT: [MessageHandler(filters.TEXT, support_message)],
            DECLINE_REASON: [MessageHandler(filters.TEXT, decline_reason)]
        },
        fallbacks=[]
    )

    app.add_handler(conv)
    app.add_handler(CallbackQueryHandler(accept, pattern="accept_"))
    app.add_handler(CallbackQueryHandler(decline, pattern="decline_"))
    app.add_handler(MessageHandler(filters.TEXT & filters.REPLY, admin_reply))

    app.run_polling()

if __name__ == "__main__":
    main()
