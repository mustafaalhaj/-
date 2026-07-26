import os
import sys
import arabic_reshaper
from bidi.algorithm import get_display

from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# 1. Register Fonts
font_path = "C:/Windows/Fonts/arial.ttf"
font_bold_path = "C:/Windows/Fonts/arialbd.ttf"

pdfmetrics.registerFont(TTFont("ArabicArial", font_path))
pdfmetrics.registerFont(TTFont("ArabicArial-Bold", font_bold_path))

def ar(text):
    """Reshape Arabic text and handle BiDi formatting."""
    if not text:
        return ""
    has_arabic = any('\u0600' <= c <= '\u06FF' for c in text)
    if has_arabic:
        reshaped = arabic_reshaper.reshape(text)
        return get_display(reshaped)
    return text

class PageNumCanvas(canvas.Canvas):
    """Subclass of canvas.Canvas for page header and page numbers."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.pages = []

    def showPage(self):
        self.pages.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self.pages)
        for page in self.pages:
            self.__dict__.update(page)
            self.draw_header_footer(num_pages)
            super().showPage()
        super().save()

    def draw_header_footer(self, total_pages):
        self.saveState()
        
        # Top Banner Header
        self.setFillColor(colors.HexColor("#1E293B"))
        self.rect(0, 750, 612, 42, fill=True, stroke=False)
        self.setFillColor(colors.HexColor("#D4AF37"))
        self.setFont("ArabicArial-Bold", 11)
        self.drawRightString(576, 765, ar("تطبيق أنا مسلم v1.0.7 — الدليل المعماري والشامل للميزات"))
        self.setFont("ArabicArial", 9)
        self.setFillColor(colors.white)
        self.drawString(36, 765, "Ana Muslim App — Master Feature Reference")
        
        # Bottom Line & Footer
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(36, 45, 576, 45)
        
        self.setFont("ArabicArial", 9)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(36, 30, ar("حقوق النشر © 2026 تطبيق أنا مسلم. جميع الحقوق محفوظة."))
        page_text = ar(f"صفحة {self._pageNumber} من {total_pages}")
        self.drawRightString(576, 30, page_text)
        
        self.restoreState()

def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=36,
        rightMargin=36,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Custom Paragraph Styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=20,
        leading=26,
        textColor=colors.HexColor("#D4AF37"),
        alignment=1, # Center
        spaceAfter=8
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#475569"),
        alignment=1,
        spaceAfter=12
    )

    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=13,
        leading=17,
        textColor=colors.HexColor("#0F172A"),
        alignment=2, # Right aligned for Arabic
        spaceBefore=10,
        spaceAfter=6
    )

    body_style = ParagraphStyle(
        'BodyArabic',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor("#334155"),
        alignment=2,
        spaceAfter=4
    )

    tbl_header = ParagraphStyle(
        'TblHeader',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=9,
        leading=12,
        textColor=colors.white,
        alignment=1
    )

    tbl_cell_ar = ParagraphStyle(
        'TblCellAr',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#1E293B"),
        alignment=2
    )

    tbl_cell_en = ParagraphStyle(
        'TblCellEn',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#1E293B"),
        alignment=0
    )

    tbl_cell_fr = ParagraphStyle(
        'TblCellFr',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#1E293B"),
        alignment=0
    )

    story = []

    # Title Block
    story.append(Spacer(1, 10))
    story.append(Paragraph(ar("الدليل الهندسي والشامل لميزات تطبيق \"أنا مسلم\" v1.0.7"), title_style))
    story.append(Paragraph(ar("Ana Muslim App — Complete 3-Language Feature & Architecture Reference Document (AR / EN / FR)"), subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor("#D4AF37"), spaceAfter=12))

    # Intro Card
    intro_p = Paragraph(ar("يقدم هذا المستند تحليلاً هندسياً شاملاً ومفصلاً لكل ميزة ومكون في تطبيق \"أنا مسلم\" الإصدار 1.0.7، المطور عبر بيئة Flutter متعددة المنصات (آيفون iOS IPA، أندرويد APK، كمبيوتر Windows EXE، وتطبيق الويب PWA). يحتوي المستند على شرح كامل باللغات العربية والإنكليزية والفرنسية."), body_style)
    story.append(intro_p)
    story.append(Spacer(1, 10))

    # Feature Tables (AR / EN / FR)
    features_data = [
        # Quran Engine
        (
            "1. محرك القرآن الكريم والتلاوات الصوتية\nNoble Quran & Audio Engine\nMoteur du Noble Coran & Récitations",
            "• 114 سورة كاملة بخط عثماني واضح وجذاب.\n• تلاوة صوتية سحابية لأشهر القراء (المعيقلي، الغامدي، العفاسي).\n• خاصية حفظ الفواصل، العلامات المرجعية، والبحث السريع.\n• إمكانية المتابعة والقراءة مع التحكم بحجم الخط والتفسير.",
            "• Complete 114 Surahs with Uthmanic font.\n• Audio recitations by top Qaris (Alafasy, Sudais, etc.).\n• Bookmark saving, search bar, & page mode.\n• Font scaling, Tafsir interpretation, and progress tracking.",
            "• 114 Sourates complètes en écriture Outhmanie.\n• Récitations audio par de grands réciteurs.\n• Marque-pages, barre de recherche et mode page.\n• Taille de police ajustable et Tafsir."
        ),
        # Prayer Times & Adhan Engine
        (
            "2. محرك مواقيت الصلاة والأذان في الخلفية\nAccurate Prayer Times & Background Adhan\nHoraires de Prière & Adhan en Arrière-plan",
            "• حساب مواقيت الصلاة بدقة 100% حسب نظام GPS الجغرافي.\n• إشعارات الأذان الكاملة في الخلفية وعلى الشاشة المقفلة.\n• دعم التنبيهات على الآيفون (iOS IPA)، الأندرويد، الويندوز، والويب.\n• تحديد اسم المدينة والموقع باللغة العربية تلقائياً.",
            "• 100% precise prayer calculation via GPS.\n• Full Adhan audio alerts on lock screen & background.\n• Multi-platform push support (iOS, Android, Windows, Web).\n• Automatic Arabic city name & reverse geocoding.",
            "• Calcul précis des heures de prière via GPS.\n• Adhan complet sur écran verrouillé & arrière-plan.\n• Support multi-plateforme (iOS, Android, PC, Web).\n• Géolocalisation automatique et nom de ville en arabe."
        ),
        # Smart Qibla & AR Compass
        (
            "3. البوصلة والقبلة الذكية ثلاثية الأبعاد\nSmart Qibla Finder & AR Compass\nBoussole Qibla Intelligente 3D",
            "• تحديد اتجاه القبلة نحو الكعبة المشرفة بدقة متناهية.\n• اعتماد كلي على مستشعرات البوصلة ومستشعر المغناطيسية.\n• عرض المسافة المباشرة بالكيلومتر بين موقعك والمكة المكرمة.\n• واجهة بوصلة تفاعلية وسلسة وتعمل بدون إنترنت.",
            "• Ultra-precise Qibla direction towards the Kaaba.\n• Relies on device magnetometer & orientation sensors.\n• Displays live distance in KM from your location to Makkah.\n• Smooth 3D compass dial working 100% offline.",
            "• Direction précise de la Qibla vers la Kaaba.\n• Utilise le magnétomètre et les capteurs du téléphone.\n• Affiche la distance exacte en km jusqu'à La Mecque.\n• Cadran boussole 3D fluide fonctionnant hors ligne."
        ),
        # Azkar & Digital Tasbih
        (
            "4. أذكار المسلم والسبحة الإلكترونية\nMuslim Azkar & Digital Tasbih\nAdhkar du Musulman & Tasbih Numérique",
            "• حصن المسلم كاملاً (أذكار الصباح، المساء، النوم، والصلاة).\n• سبحة إلكترونية متطورة مع عداد ذكي واستجابة اهتزازية (Haptics).\n• إمكانية تخصيص أهداف الذكر وتصفير العداد بلمسة واحدة.\n• إحصائيات التقدّم الصوتي والقرائي للذكر اليومي.",
            "• Complete Hisn al-Muslim (Morning, Evening, Sleep, Prayer).\n• Smart Digital Tasbih with haptic feedback vibration.\n• Customizable target goals and one-tap reset counter.\n• Daily Zikr tracking & progress indicators.",
            "• Hisn al-Muslim complet (Matin, Soir, Sommeil, Prière).\n• Tasbih numérique intelligent avec retours haptiques.\n• Objectifs personnalisables et réinitialisation en un clic.\n• Suivi quotidien des invocations et statistiques."
        ),
        # Fasting Tracker & Hijri Calendar
        (
            "5. متابع الصيام والتقويم الهجري\nFasting Tracker & Hijri Calendar\nSuivi du Jeûne & Calendrier Hégirien",
            "• متابعة صيام رمضان والأيام البيض (13، 14، 15) والإثنين والخميس.\n• عداد الأيام المتتالية لصيام التطوع والتنبيهات المسبقة للسحور والإفطار.\n• تقويم هجري وميلادي مدمج يعرض المناسبات الأسلامية.\n• حساب فرق الأيام الهجرية بدقة عالية.",
            "• Track Ramadan, White Days (13, 14, 15), Mondays & Thursdays.\n• Fasting streak counter & Suhoor/Iftar notifications.\n• Dual Hijri & Gregorian calendar with Islamic events.\n• High accuracy Hijri adjustment setting.",
            "• Suivi du Ramadan, Jours Blancs, Lundi et Jeudi.\n• Compteur de jours de jeûne & rappels Suhoor/Iftar.\n• Calendrier combiné Hégirien/Grégorien avec événements.\n• Réglage de précision du calendrier hégirien."
        ),
        # AI Islamic Assistant
        (
            "6. المساعد الذكي بالذكاء الاصطناعي\nSmart AI Islamic Assistant\nAssistant Islamique IA Intelligent",
            "• مساعد ذكي مدعوم بنموذج Google Gemini Flash الاصطناعي.\n• الإجابة على الاستفسارات الفقهية والإسلامية العامة بسرعة فائقة.\n• المساعدة في البحث عن الآيات، مواقيت الصيام، والأحكام.\n• تقديم اقتراحات وإشعارات يومية ذكية مخصصة للمستخدم.",
            "• AI Assistant powered by Google Gemini Flash engine.\n• Fast answers to general Islamic & fasting queries.\n• Helps search Quranic verses, fasting rules, & guidance.\n• Generates smart daily reminders tailored to user state.",
            "• Assistant IA propulsé par Google Gemini Flash.\n• Réponses rapides aux questions islamiques et du jeûne.\n• Aide à la recherche de versets et règles religieuses.\n• Invocations et rappels intelligents quotidiens."
        ),
        # Asmaul Husna, Hadith & Mood Quran
        (
            "7. أسماء الله الحسنى، الأحاديث، والقرآن حسب الحالة\nAsmaul Husna, Hadiths & Mood-Based Quran\nNoms d'Allah, Hadiths & Coran selon l'humeur",
            "• أسماء الله الحسنى 99 كاملة مع معانيها والتلاوة الصوتية.\n• الأربعون النووية وكتب الأحاديث الصحيحة مع الشرح.\n• خيار \"كيف تشعر اليوم؟\" لاستخراج الآيات والأدعية المناسبة لحالتك.\n• البث المباشر 24/7 من الحرم المكي والمسجد النبوي الشريف.",
            "• 99 Names of Allah with meanings & audio pronunciations.\n• An-Nawawi 40 Hadiths & authentic hadith collections.\n• 'How are you feeling?' mode returning matching Quran verses.\n• 24/7 Live Stream from Makkah & Madinah Mosques.",
            "• 99 Noms d'Allah avec significations et audio.\n• 40 Hadiths Nawawi et collections authentiques.\n• Mode 'Comment vous sentez-vous ?' avec versets adaptés.\n• Direct 24/7 depuis La Mecque et Médine."
        ),
        # Multi-Platform Engineering
        (
            "8. التوافقية المتعددة للمنصات والتثبيت\nMulti-Platform Engineering & Install Guide\nIngénierie Multi-Plateforme & Installation",
            "• نسخة الآيفون (iOS IPA v1.0.7): تثبيت آمن بـ Sideloadly.\n• نسخة الأندرويد (Android APK): تثبيت مباشر وسريع.\n• نسخة الكمبيوتر (Windows EXE): تطبيق مكتبي كامل مستقل.\n• تطبيق الويب المباشر (Web PWA): إشعارات الأذان حتى لو أغلق المتصفح.",
            "• iPhone (iOS IPA v1.0.7): Safe Sideloadly installation.\n• Android (APK): Direct fast APK download.\n• Windows Desktop (EXE): Full standalone desktop app.\n• Web PWA: Web Push notifications even when tab is closed.",
            "• iPhone (iOS IPA v1.0.7) : Installation via Sideloadly.\n• Android (APK) : Téléchargement APK direct.\n• Windows PC (EXE) : App autonome pour ordinateur.\n• Web PWA : Notifications Web Push même fermé."
        ),
        # Privacy & Offline
        (
            "9. الخصوصية والعمل بدون إنترنت\nPrivacy, Security & Offline Operations\nConfidentialité, Sécurité & Hors-ligne",
            "• عمل 100% بدون إنترنت للميزات الأساسية (قرآن، أذكار، قبلة).\n• خالي تماماً من الإعلانات المزعجة لوجه الله تعالى.\n• حماية الخصوصية 100%: لا يتم جمع أي بيانات شخصية أو تتبع.\n• حفظ التفضيلات وم مواقع الصلاة محلياً على الجهاز بأمان.",
            "• 100% offline functionality for core features.\n• 100% ad-free experience purely for the sake of Allah.\n• Complete privacy protection: No tracking or data collection.\n• Local secure storage of all user settings & bookmarks.",
            "• Fonctionnement 100% hors ligne des fonctions de base.\n• 100% sans publicité, dédié à Allah.\n• Protection de la vie privée : Aucun suivi ni collecte.\n• Stockage local sécurisé des préférences et marque-pages."
        )
    ]

    for idx, (sec_title, text_ar, text_en, text_fr) in enumerate(features_data, 1):
        story.append(Paragraph(ar(sec_title), h1_style))
        story.append(Spacer(1, 4))

        tbl_data = [
            [
                Paragraph(ar("اللغة العربية (Arabic 🇸🇦)"), tbl_header),
                Paragraph("English (🇬🇧)", tbl_header),
                Paragraph("Français (🇫🇷)", tbl_header)
            ],
            [
                Paragraph(ar(text_ar), tbl_cell_ar),
                Paragraph(text_en, tbl_cell_en),
                Paragraph(text_fr, tbl_cell_fr)
            ]
        ]

        t = Table(tbl_data, colWidths=[180, 180, 180])
        t.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#1E293B")),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
            ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor("#F8FAFC")),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('LEFTPADDING', (0, 0), (-1, -1), 6),
            ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ]))

        story.append(t)
        story.append(Spacer(1, 10))

    # Footer note
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#D4AF37"), spaceAfter=8))
    final_note = Paragraph(ar("تم إصدار وتوثيق هذا المستند المعماري الشامل بواسطة الفريق التقني لتطبيق \"أنا مسلم\" الإصدار v1.0.7 لعام 2026. جميع الحقوق محفوظة لـ Mustafa Alhaj Mustafa."), subtitle_style)
    story.append(final_note)

    doc.build(story, canvasmaker=PageNumCanvas)
    print(f"Full features PDF build successful: {filename}")

if __name__ == "__main__":
    out_pdf = "AnaMuslim_Full_Features_Document.pdf"
    build_pdf(out_pdf)
