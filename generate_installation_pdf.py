import os
import arabic_reshaper
from bidi.algorithm import get_display
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# 1. Register Arabic TTF Font
font_path = "C:/Windows/Fonts/arial.ttf"
font_bold_path = "C:/Windows/Fonts/arialbd.ttf"

pdfmetrics.registerFont(TTFont("ArabicArial", font_path))
pdfmetrics.registerFont(TTFont("ArabicArial-Bold", font_bold_path))

def ar(text):
    """Helper function to reshape Arabic text and handle BiDi text direction."""
    if not text:
        return ""
    reshaped = arabic_reshaper.reshape(text)
    return get_display(reshaped)

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        
        # Draw Header
        self.setFillColor(colors.HexColor("#1E1B4B"))
        self.rect(0, 750, 612, 42, fill=True, stroke=False)
        self.setFillColor(colors.HexColor("#FACC15"))
        self.setFont("ArabicArial-Bold", 10)
        self.drawRightString(580, 765, ar("تطبيق أنا مسلم v1.0.7 - دليل التثبيت والتشغيل الشامل"))
        self.drawString(30, 765, ar("Ana Muslim App Guide"))
        
        # Draw Footer
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.8)
        self.line(30, 45, 582, 45)
        
        self.setFont("ArabicArial", 9)
        self.setFillColor(colors.HexColor("#64748B"))
        page_text = ar(f"صفحة {self._pageNumber} من {page_count}")
        self.drawCentredString(306, 30, page_text)
        self.drawString(30, 30, ar("© 2026 جميع الحقوق محفوظة - مصطفى الحاج مصطفى"))
        self.restoreState()

def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=30,
        rightMargin=30,
        topMargin=55,
        bottomMargin=55
    )

    styles = getSampleStyleSheet()
    
    # Custom Arabic Styles
    style_title = ParagraphStyle(
        'ArabicTitle',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=22,
        leading=28,
        textColor=colors.HexColor("#1E1B4B"),
        alignment=1, # Center
        spaceAfter=15
    )
    
    style_subtitle = ParagraphStyle(
        'ArabicSubtitle',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=12,
        leading=18,
        textColor=colors.HexColor("#475569"),
        alignment=1, # Center
        spaceAfter=25
    )
    
    style_h1 = ParagraphStyle(
        'ArabicH1',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=15,
        leading=20,
        textColor=colors.HexColor("#065F46"),
        alignment=2, # Right
        spaceBefore=15,
        spaceAfter=10
    )

    style_h2 = ParagraphStyle(
        'ArabicH2',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor("#1E1B4B"),
        alignment=2, # Right
        spaceBefore=10,
        spaceAfter=6
    )

    style_body = ParagraphStyle(
        'ArabicBody',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=10,
        leading=15,
        textColor=colors.HexColor("#1E293B"),
        alignment=2, # Right
        spaceAfter=8
    )

    style_alert = ParagraphStyle(
        'ArabicAlert',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=9.5,
        leading=14,
        textColor=colors.HexColor("#854D0E"),
        alignment=2,
    )

    story = []

    # --- Title Banner ---
    story.append(Spacer(1, 10))
    story.append(Paragraph(ar("دليل التثبيت والتشغيل الشامل - تطبيق أنا مسلم v1.0.7"), style_title))
    story.append(Paragraph(ar("شرح مفصل بالخطوات لتثبيت التطبيق على الآيفون (iOS IPA)، الأندرويد (APK)، الكمبيوتر (Windows)، والويب (PWA)"), style_subtitle))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor("#FACC15"), spaceAfter=15))

    # --- Important Note Box ---
    alert_text = ar("📌 ملاحظة هامة: هذا الدليل يوضح خطوات تثبيت الإصدار الجديد 1.0.7 المحدث بكافة الميزات، بما فيها تشغيل الأذان في الخلفية، تحديد الموقع باللغة العربية، ودعم جميع أجهزة الآيفون والأندرويد والكمبيوتر.")
    alert_table = Table([[Paragraph(alert_text, style_alert)]], colWidths=[540])
    alert_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#FEF9C3")),
        ('BORDER', (0,0), (-1,-1), 1, colors.HexColor("#FACC15")),
        ('PADDING', (0,0), (-1,-1), 10),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(alert_table)
    story.append(Spacer(1, 15))

    # --- SECTION 1: iOS IPA Installation Guide ---
    story.append(Paragraph(ar("🍏 القسم الأول: دليل تثبيت نسخة الآيفون (iOS IPA v1.0.7) عبر Sideloadly"), style_h1))
    story.append(Paragraph(ar("نظراً لأن التحديث الجديد بصيغة Runner.ipa وغير متوفر حالياً على متجر App Store، يمكنك تثبيته بسهولة وأمان تام على آيفونك خلال 3 دقائق باستخدام برنامج Sideloadly المجاني والكمبيوتر:"), style_body))

    ios_steps = [
        [ar("الخطوة"), ar("البيان والخطوات التفصيلية للتثبيت")],
        [ar("1. تنزيل ملف IPA"), ar("قم بتنزيل ملف Runner.ipa v1.0.7 الخاص بالتطبيق وحفظه على جهاز الكمبيوتر الخاص بك من الموقع أو روابط GitHub.")],
        [ar("2. برامج Apple"), ar("قم بتنزيل برنامجي iTunes و iCloud من موقع Apple أو متجر Microsoft على كمبيوتر الويندوز وسجل دخولك بـ Apple ID.")],
        [ar("3. أداة Sideloadly"), ar("قم بتنزيل أداة التثبيت الآمنة والمجانية Sideloadly من موقعها الرسمي (sideloadly.io) وتثبيتها على الكمبيوتر.")],
        [ar("4. التوصيل والتثبيت"), ar("وصل الآيفون بالكمبيوتر بكابل USB 👈 افتح Sideloadly واكتب بريد Apple ID 👈 اسقط ملف Runner.ipa 👈 اضغط Start وانتظر كلمة DONE.")],
        [ar("5. توثيق الشهادة"), ar("على الآيفون افتح: الإعدادات 👈 عام 👈 إدارة الجهاز والـ VPN 👈 اضغط على إيميلك واختر (الوثوق). افتح التطبيق واستمتع بالأذان!")],
    ]

    t_ios = Table(ios_steps, colWidths=[110, 430])
    t_ios.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E1B4B")),
        ('TEXTCOLOR', (0,0), (-1,0), colors.HexColor("#FACC15")),
        ('FONTNAME', (0,0), (-1,0), 'ArabicArial-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 10),
        ('ALIGN', (0,0), (-1,-1), 'RIGHT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('BACKGROUND', (0,1), (-1,1), colors.HexColor("#F8FAFC")),
        ('BACKGROUND', (0,3), (-1,3), colors.HexColor("#F8FAFC")),
        ('BACKGROUND', (0,5), (-1,5), colors.HexColor("#FEF9C3")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_ios)
    story.append(Spacer(1, 15))

    # --- SECTION 2: Android APK Guide ---
    story.append(Paragraph(ar("🤖 القسم الثاني: دليل تثبيت نسخة الأندرويد (Android APK v1.0.7)"), style_h1))
    
    android_steps = [
        [ar("الخطوة"), ar("الإجراء المطلوب")],
        [ar("1. تنزيل APK"), ar("اضغط على زر (تحميل APK) لتنزيل حزمة التثبيت المباشرة v1.0.7 على هاتفك الأندرويد.")],
        [ar("2. التثبيت المباشر"), ar("افتح الملف المنازل واضغط (تثبيت). إذا ظهر تنبيه، اختر السماح بتثبيت التطبيقات من هذا المصدر.")],
        [ar("3. ضبط الأذان"), ar("عند الفتح لأول مرة، وافق على إذن الإشعارات وقم بإلغاء تقييد البطارية للتطبيق ليطلق الأذان كاملاً.")],
    ]

    t_android = Table(android_steps, colWidths=[110, 430])
    t_android.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#065F46")),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'ArabicArial-Bold'),
        ('ALIGN', (0,0), (-1,-1), 'RIGHT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_android)
    story.append(Spacer(1, 15))

    # --- SECTION 3: Windows Desktop Guide ---
    story.append(Paragraph(ar("💻 القسم الثالث: دليل تشغيل نسخة الكمبيوتر (Windows Desktop EXE)"), style_h1))
    
    win_steps = [
        [ar("الخطوة"), ar("الإجراء المطلوب")],
        [ar("1. فك الضغط"), ar("قم بتنزيل حزمة الكمبيوتر المضغوطة وفك الضغط عنها في أي مجلد على قرص الكمبيوتر.")],
        [ar("2. التشغيل المباشر"), ar("اضغط مرتين على ملف flutter_application_1.exe لتشغيل التطبيق المكتبي المستقل فوراً.")],
        [ar("3. تفعيل الموقع"), ar("وافق على إذن الموقع الجغرافي والإشعارات ليتعرف التطبيق على اسم مدينتك باللغة العربية ويحسب الأذان.")],
    ]

    t_win = Table(win_steps, colWidths=[110, 430])
    t_win.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1D4ED8")),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'ArabicArial-Bold'),
        ('ALIGN', (0,0), (-1,-1), 'RIGHT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_win)
    story.append(Spacer(1, 15))

    # --- SECTION 4: Web App PWA Guide ---
    story.append(Paragraph(ar("🌐 القسم الرابع: دليل تشغيل تطبيق الويب المباشر (Web PWA)"), style_h1))
    story.append(Paragraph(ar("يعمل تطبيق الويب فورياً عبر المتصفح (Chrome, Edge, Safari) ويتميز بدعم إشعارات الويب الدائمة (Service Worker) حتى بعد إغلاق المتصفح أو الصفحة:"), style_body))
    
    web_steps = [
        [ar("الميزة"), ar("طريقة الاستفادة منها")],
        [ar("إشعارات الويب"), ar("افتح رابط الويب واضغط (سماح) على منبثق المتصفح لمنح إذن الإشعارات السحابية المباشرة.")],
        [ar("تثبيت PWA"), ar("اضغط على خيارات المتصفح اختر (تثبيت التطبيق على سطح المكتب / الهاتف) ليصبح تطبيقا مدمجا.")],
    ]

    t_web = Table(web_steps, colWidths=[110, 430])
    t_web.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#7E22CE")),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'ArabicArial-Bold'),
        ('ALIGN', (0,0), (-1,-1), 'RIGHT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_web)
    story.append(Spacer(1, 20))

    # --- SECTION 5: FAQ & Troubleshooting ---
    story.append(Paragraph(ar("❓ النصائح الذهبية وحل المشاكل الشائعة"), style_h1))
    
    faq_box = ar("• لم أسمع صوت الأذان في الآيفون؟ تأكد من إلغاء وضع الصامت الجانيي للآيفون، وتأكد من تفعيل الأصوات من إعدادات الآيفون -> الإشعارات -> أنا مسلم.\n• لم تظهر الإشعارات على الأندرويد؟ اذهب إلى إعدادات الهاتف -> التطبيقات -> أنا مسلم -> العناية بالبطارية واختر (غير مقيد).\n• هل يمكن تثبيت ملف IPA بدون كمبيوتر؟ التثبيت عبر Sideloadly بالكمبيوتر هو الأضمن والأكثر استقراراً بدون توقف الشهادات.")
    
    t_faq = Table([[Paragraph(faq_box, style_body)]], colWidths=[540])
    t_faq.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F1F5F9")),
        ('BORDER', (0,0), (-1,-1), 1, colors.HexColor("#94A3B8")),
        ('PADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_faq)

    doc.build(story, canvasmaker=NumberedCanvas)
    print("PDF build successful:", filename)

if __name__ == "__main__":
    output_pdf = "c:/Users/musta/Desktop/my all project/Anamuslim/flutter_application_1/دليل_التثبيت_الشامل_تطبيق_أنا_مسلم_v1.0.7.pdf"
    build_pdf(output_pdf)
