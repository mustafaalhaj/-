import os
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas
import arabic_reshaper
from bidi.algorithm import get_display

def ar(text):
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
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#718096"))
        
        # Header (pages > 1)
        if self._pageNumber > 1:
            self.setStrokeColor(colors.HexColor("#CBD5E0"))
            self.setLineWidth(0.5)
            self.line(40, 800, 555, 800)
            self.drawString(40, 805, "Ana Muslim Application - Notification System Architecture Report")
        
        # Footer
        self.setStrokeColor(colors.HexColor("#CBD5E0"))
        self.setLineWidth(0.5)
        self.line(40, 45, 555, 45)
        
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(555, 30, page_str)
        self.drawString(40, 30, ar("تطبيق أنا مسلم - تقرير نظام الإشعارات الشامل"))
        self.restoreState()

def build_pdf(pdf_path):
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=A4,
        leftMargin=40,
        rightMargin=40,
        topMargin=50,
        bottomMargin=60
    )

    # Register Arabic Font if available, else standard
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont
    
    font_name = "Helvetica"
    font_bold = "Helvetica-Bold"
    
    arabic_font_path = "C:/Windows/Fonts/arial.ttf"
    arabic_bold_path = "C:/Windows/Fonts/arialbd.ttf"
    
    if os.path.exists(arabic_font_path):
        pdfmetrics.registerFont(TTFont('ArabicFont', arabic_font_path))
        pdfmetrics.registerFont(TTFont('ArabicFont-Bold', arabic_bold_path))
        font_name = 'ArabicFont'
        font_bold = 'ArabicFont-Bold'

    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName=font_bold,
        fontSize=22,
        leading=28,
        textColor=colors.HexColor('#1A365D'),
        alignment=1, # Center
        spaceAfter=15
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName=font_name,
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#4A5568'),
        alignment=1,
        spaceAfter=20
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName=font_bold,
        fontSize=15,
        leading=20,
        textColor=colors.HexColor('#2C5282'),
        alignment=2, # Right align for Arabic
        spaceBefore=15,
        spaceAfter=8
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName=font_name,
        fontSize=10,
        leading=15,
        textColor=colors.HexColor('#2D3748'),
        alignment=2,
        spaceAfter=6
    )

    bullet_style = ParagraphStyle(
        'Bullet_Custom',
        parent=styles['Normal'],
        fontName=font_name,
        fontSize=10,
        leading=15,
        textColor=colors.HexColor('#2D3748'),
        alignment=2,
        rightIndent=15,
        spaceAfter=4
    )

    story = []

    # Title & Header
    story.append(Paragraph(ar("تقرير المعمارية الشاملة لنظام الإشعارات"), title_style))
    story.append(Paragraph(ar("تطبيق أنا مسلم (Ana Muslim) - الإصدار 1.0.7"), subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor('#3182CE'), spaceAfter=15))

    # 1. Summary
    story.append(Paragraph(ar("1. الملخص التنفيذي"), h1_style))
    story.append(Paragraph(ar("تم بناء نظام إشعارات متطور ثنائي الطبقات يجمع بين الأتمتة السحابية الذكية والعمل المحلي بدون إنترنت (Offline-First)، مع الحفاظ التام 100% على كافة الخدمات السابقة للتطبيق وإتاحة التحكم الكامل للمستخدم لضبط خياراته الشخصية في تلقي الإشعارات وتحديد مواعيدها."), body_style))

    story.append(Spacer(1, 10))

    # 2. Architecture Layers
    story.append(Paragraph(ar("2. مكونات معمارية النظام ثنائي الطبقات"), h1_style))
    
    table_data = [
        [ar("التفاصيل والخصائص"), ar("المحرك / التقنية المستخدمة"), ar("الطبقة / المكون")],
        [
            ar("جدولة أوقات الصلاة بالأذان الصوتي، أذكار الصباح والمساء، تذكير الجمعة لسورة الكهف، قيام الليل، وتنبيهات الصيام."),
            ar("FlutterLocalNotificationsPlugin + Timezone + WorkManager"),
            ar("الطبقة 1: المحرك المحلي (Offline)")
        ],
        [
            ar("إشعارات الآيات، الأحاديث، الأذكار اليومية والإعلانات الطارئة الموجهة للمستخدمين بصورة آمنة ومجانية 100%."),
            ar("Firebase Cloud Messaging (FCM Topics) + Cloud Functions"),
            ar("الطبقة 2: المحرك السحابي (Remote)")
        ],
        [
            ar("شاشة زجاجية مخصصة تمكّن المستخدم من تفعيل/تعطيل كل صلاة وأذكار الصباح والمساء والكهف ومواضيع FCM."),
            ar("NotificationPreferencesProvider + SharedPreferences"),
            ar("تفضيلات المستخدم (User Preferences)")
        ]
    ]

    t = Table(table_data, colWidths=[240, 160, 115])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2B6CB0')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), font_bold),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F7FAFC')]),
    ]))
    story.append(t)

    story.append(Spacer(1, 15))

    # 3. Security & Safety
    story.append(Paragraph(ar("3. الأمان وسلامة البيانات (Security Protocol)"), h1_style))
    story.append(Paragraph(ar("• الإرسال السحابي الآمن: يتم الإرسال حصرياً من داخل لوحة Firebase Console الرسمية الخاصة بالمطور مع حماية تامة تمنع خروج أي كود إرسال من هواتف المستخدمين."), bullet_style))
    story.append(Paragraph(ar("• منع التكرار (Deduplication): اعتماد معرفات فريدة لكل إشعار محلي لمنع تكرار الإشعار أو مضاعفة الصوت."), bullet_style))
    story.append(Paragraph(ar("• التوجيه الذكي (Deep Linking): توجيه المستخدم فور النقر على الإشعار إلى صفحة الآية أو الحديث المعني مباشرة."), bullet_style))

    story.append(Spacer(1, 15))

    # 4. Status & Results
    story.append(Paragraph(ar("4. نتائج الفحص والبناء النهائي"), h1_style))
    story.append(Paragraph(ar("• فحص الكود (Flutter Analyze): خالي 100% من الأخطاء والتحذيرات (No issues found)."), bullet_style))
    story.append(Paragraph(ar("• ملف APK النهائي (التثبيت المباشر): جاهز بحجم ~98.9 ميغابايت (app-release.apk)."), bullet_style))
    story.append(Paragraph(ar("• ملف AAB النهائي (رفع جوجل بلاي): جاهز بحجم ~46.7 ميغابايت (app-release.aab)."), bullet_style))

    doc.build(story, canvasmaker=NumberedCanvas)
    print("PDF build successful!")

if __name__ == "__main__":
    artifact_dir = r"C:\Users\musta\.gemini\antigravity-ide\brain\035758fe-ff3e-4f0d-9d35-d055669cd7aa"
    pdf_path = os.path.join(artifact_dir, "Ana_Muslim_Notification_System_Report.pdf")
    build_pdf(pdf_path)
