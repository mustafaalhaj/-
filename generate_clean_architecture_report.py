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

class CleanArchCanvas(canvas.Canvas):
    """Canvas subclass for adding elegant headers, footers, and page numbers."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.pages = []

    def showPage(self):
        self.pages.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self.pages)
        for idx, page in enumerate(self.pages, 1):
            self.__dict__.update(page)
            if idx > 1: # Skip cover page header/footer
                self.draw_header_footer(num_pages, idx)
            super().showPage()
        super().save()

    def draw_header_footer(self, total_pages, current_page):
        self.saveState()
        
        # Header Banner
        self.setFillColor(colors.HexColor("#00C030")) # Emerald Green Accent
        self.rect(0, 755, 612, 37, fill=True, stroke=False)
        self.setFillColor(colors.white)
        self.setFont("ArabicArial-Bold", 10)
        self.drawRightString(576, 767, ar("تقرير البنية المعمارية الشاملة والميزات — تطبيق أنا مسلم v1.0.7"))
        self.setFont("ArabicArial", 9)
        self.drawString(36, 767, "Ana Muslim App — Technical Architecture Report")
        
        # Footer
        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(36, 42, 576, 42)
        
        self.setFont("ArabicArial", 8.5)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(36, 28, ar("تقرير البنية التقنية والميزات 100% بدون تكلفة أو ساعات عمل"))
        page_str = ar(f"صفحة {current_page} من {total_pages}")
        self.drawRightString(576, 28, page_str)
        
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

    # Paragraph Styles
    cover_title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=22,
        leading=28,
        textColor=colors.HexColor("#00C030"),
        alignment=1, # Center
        spaceAfter=12
    )

    cover_subtitle_style = ParagraphStyle(
        'CoverSubTitle',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor("#475569"),
        alignment=1,
        spaceAfter=20
    )

    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=13,
        leading=17,
        textColor=colors.HexColor("#0F172A"),
        alignment=2, # Right
        spaceBefore=14,
        spaceAfter=6
    )

    h2_style = ParagraphStyle(
        'H2',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=10.5,
        leading=14,
        textColor=colors.HexColor("#00C030"),
        alignment=2,
        spaceBefore=8,
        spaceAfter=4
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor("#334155"),
        alignment=2,
        spaceAfter=5
    )

    tbl_header_style = ParagraphStyle(
        'TH',
        parent=styles['Normal'],
        fontName='ArabicArial-Bold',
        fontSize=9,
        leading=12,
        textColor=colors.white,
        alignment=1
    )

    tbl_cell_style = ParagraphStyle(
        'TD',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor("#1E293B"),
        alignment=2
    )

    tbl_cell_en_style = ParagraphStyle(
        'TD_EN',
        parent=styles['Normal'],
        fontName='ArabicArial',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor("#1E293B"),
        alignment=0
    )

    story = []

    # --- COVER PAGE ---
    story.append(Spacer(1, 40))
    story.append(Paragraph(ar("مراجعة البنية البرمجية والتفكيك الشامل لمشروع \"أنا مسلم\""), cover_title_style))
    story.append(Paragraph(ar("Ana Muslim App — Senior Software Architecture & Technical Audit"), cover_subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor("#00C030"), spaceAfter=30))

    # Meta Table on Cover
    meta_data = [
        [Paragraph(ar("إصدار التطبيق (App Version):"), tbl_cell_style), Paragraph("v1.0.7+7 (Production)", tbl_cell_en_style)],
        [Paragraph(ar("إطار العمل (Framework):"), tbl_cell_style), Paragraph("Flutter 3.10+ (Dart SDK ^3.10.1)", tbl_cell_en_style)],
        [Paragraph(ar("نمط المعمارية (Architecture):"), tbl_cell_style), Paragraph("Service-Oriented Architecture + Provider", tbl_cell_en_style)],
        [Paragraph(ar("دعم المنصات (Platforms):"), tbl_cell_style), Paragraph("iOS (IPA), Android (APK), Windows (EXE), Web (PWA)", tbl_cell_en_style)],
        [Paragraph(ar("تاريخ التقرير المعماري:"), tbl_cell_style), Paragraph("2026", tbl_cell_en_style)]
    ]
    meta_tbl = Table(meta_data, colWidths=[240, 300])
    meta_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(meta_tbl)
    story.append(Spacer(1, 40))
    story.append(Paragraph(ar("بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ"), ParagraphStyle('Bismillah', fontName='ArabicArial-Bold', fontSize=14, leading=18, alignment=1, textColor=colors.HexColor("#D4AF37"))))
    story.append(PageBreak())

    # --- SECTION 1: EXECUTIVE SUMMARY & USER JOURNEY ---
    story.append(Paragraph(ar("1. الملخص التنفيذي ورحلة المستخدم (Executive Summary & User Journey)"), h1_style))
    story.append(Paragraph(ar("تطبيق \"أنا مسلم\" هو تطبيق إسلامي شامل عبر المنصات (Cross-Platform) تم تطويره باستعمال إطار العمل Flutter لتقديم تجربة إيمانية متكاملة تجمع بين القرآن الكريم، مواقيت الصلاة والأذان، الققبلة بالواقع المعزز (AR)، الأذكار، الذكاء الاصطناعي (Gemini 2.0 Flash)، وتتبع الصيام."), body_style))
    
    story.append(Paragraph(ar("الرؤية المعمارية للتطبيق:"), h2_style))
    story.append(Paragraph(ar("يعتمد التطبيق على معمارية فصل الخدمات (Service-Oriented Architecture) مع إدارة حالة مركزية مبسطة باستخدام Provider، وتصميم عصري يعتمد على المؤثرات الزجاجية (Glassmorphism Neumorphic UI Design)، مع تحسينات أداء عالية لعزل إعادة الرسم (Repaint Boundary) وتوفير سرعة 60/120 إطار في الثانية."), body_style))

    story.append(Paragraph(ar("تتبع سير ورحلة المستخدم (User Journey):"), h2_style))
    story.append(Paragraph(ar("• 01. شاشة البداية والتهيئة: تحميل سريع بالشعار وتلاشي أنيق خلال 1.5 ثانية مع تهيئة غير حجابة لخدمات Firebase والإشعارات."), body_style))
    story.append(Paragraph(ar("• 02. فلسفة المصادقة بدون تعقيد (Guest-First Model): لا يجبر المستخدم على إنشاء حساب أو إدخال بيانات شخصية لحماية الخصوصية 100%."), body_style))
    story.append(Paragraph(ar("• 03. اللوحة الرئيسية والشريط الزجاجي: تنقل سلس بين 5 أقسام (القرآن، الصلاة، الرئيسية، الأذكار، والمزيد)."), body_style))
    story.append(Paragraph(ar("• 04. إنجاز المهام الأساسية: تشغيل تلاوات القرآن في الخلفية عبر just_audio، بوصلة القبلة بالواقع المعزز، ومحادثة المساعد الذكي AI."), body_style))
    story.append(Spacer(1, 10))

    # --- SECTION 2: COMPREHENSIVE FEATURES BREAKDOWN ---
    story.append(Paragraph(ar("2. التفكيك الشامل للوظائف والميزات (Comprehensive Features Breakdown)"), h1_style))
    
    features_list = [
        ("1. وحدة القرآن الكريم والتلاوات الصوتية", "عرض 114 سورة كاملة، تشغيل صوتي سحابي لأشهر القراء بـ just_audio في الخلفية، التحكم بحجم الخط والتفسير."),
        ("2. وحدة مواقيت الصلاة والأذان التفاعلية", "حساب جغرافي دقيق عبر adhan و geolocator، تنبيهات أذان مجدولة بالثواني عبر workmanager، وويدجت الشاشة الرئيسية للأندرويد."),
        ("3. بوصلة القبلة بالواقع المعزز (AR Qibla)", "تحديد الاتجاه بدقة عبر flutter_compass، مع رؤية الواقع المعزز للكاميرا واسقاط سهم القبلة 3D فوق العالم الحقيقي."),
        ("4. المساعد الإسلامي الذكي (AI Gemini)", "تكامل مباشر مع نموذج Google Gemini 2.0 Flash للإجابة عن الأسئلة الفقهية والتفسير وتوليد تنبيهات يومية ذكية."),
        ("5. الأذكار والأدعية والمسبحة الرقمية", "حصن المسلم كاملاً، سبحة إلكترونية ذكية مع اهتزاز لمسي (Haptic Feedback)، وعرض أسماء الله الحسنى 99 بالصوت والشر ح."),
        ("6. مكتبة الأحاديث النبوية الشاملة", "عرض الأربعون النووية وصحيح البخاري ومسلم، مع محرك بحث نصي محلي سريع وتصدير ومشاركة."),
        ("7. متتبع الحالة النفسية والمزاج الإيماني", "خيار 'كيف تشعر اليوم؟' لاقتراح الآيات والأدعية المناسبة لتهدئة النفس وتقوية الإيمان في لحظتها."),
        ("8. البث المباشر لقنوات الحرمين", "بث تلفزيوني حي 24/7 لقناة القرآن الكريم من مكة المكرمة وقناة السنة النبوية من المدينة المنورة."),
        ("9. التقويم الهجري ومتتبع الصيام", "حساب التواريخ والمناسبات، تسجيل أيام صيام رمضان والأيام البيض والإثنين والخميس وتنبيهات السحور والإفطار."),
        ("10. تخصيص الواجهة والسمات (UI Customization)", "محرر اللوحة الرئيسية لإعادة ترتيب البطاقات، ودعم الدارك مود الزجاجي الشامل عبر ThemeProvider.")
    ]

    for title, desc in features_list:
        story.append(Paragraph(ar(title), h2_style))
        story.append(Paragraph(ar(desc), body_style))

    story.append(Spacer(1, 10))

    # --- SECTION 3: PERMISSIONS AUDIT ---
    story.append(Paragraph(ar("3. جرد الأذونات والتراخيص ومستوى الخطورة (Permissions Audit)"), h1_style))
    
    perm_header = [
        Paragraph(ar("إسم الإذن (Permission)"), tbl_header_style),
        Paragraph(ar("الغرض الوظيفي للمستخدم"), tbl_header_style),
        Paragraph(ar("السبب البرمجي والخدمة"), tbl_header_style),
        Paragraph(ar("درجة الخطورة"), tbl_header_style)
    ]

    perm_rows = [
        perm_header,
        [Paragraph("ACCESS_FINE_LOCATION", tbl_cell_en_style), Paragraph(ar("تحديد موقع الجهاز الحالي"), tbl_cell_style), Paragraph(ar("حساب أوقات الصلاة والقبلة بمكتبة adhan"), tbl_cell_style), Paragraph(ar("متوسطة"), tbl_cell_style)],
        [Paragraph("POST_NOTIFICATIONS", tbl_cell_en_style), Paragraph(ar("عرض إشعارات الأذان والأذكار"), tbl_cell_style), Paragraph(ar("السماح بخروج التنبيهات في Android 13+ و iOS"), tbl_cell_style), Paragraph(ar("منخفضة"), tbl_cell_style)],
        [Paragraph("SCHEDULE_EXACT_ALARM", tbl_cell_en_style), Paragraph(ar("تنبيه الأذان بالثانية في وقته"), tbl_cell_style), Paragraph(ar("جدولة المنبهات الدقيقة لضمان عدم التأخير"), tbl_cell_style), Paragraph(ar("متوسطة"), tbl_cell_style)],
        [Paragraph("RECEIVE_BOOT_COMPLETED", tbl_cell_en_style), Paragraph(ar("استمرار التنبيهات بعد إعادة التشغيل"), tbl_cell_style), Paragraph(ar("إعادة جدولة التنبيهات فور تشغيل الهاتف"), tbl_cell_style), Paragraph(ar("منخفضة"), tbl_cell_style)],
        [Paragraph("FOREGROUND_SERVICE", tbl_cell_en_style), Paragraph(ar("استمرار صوت التلاوة والأذان"), tbl_cell_style), Paragraph(ar("منع النظام من إيقاف الخدمة الصوتية بالخلفية"), tbl_cell_style), Paragraph(ar("منخفضة"), tbl_cell_style)],
        [Paragraph("CAMERA", tbl_cell_en_style), Paragraph(ar("رؤية القبلة بالواقع المعزز AR"), tbl_cell_style), Paragraph(ar("فتح الكاميرا لتراكب سهم القبلة 3D"), tbl_cell_style), Paragraph(ar("عالية (بموافقة)"), tbl_cell_style)],
        [Paragraph("VIBRATE", tbl_cell_en_style), Paragraph(ar("الاستجابة اللمسية عند التسبيح"), tbl_cell_style), Paragraph(ar("تفعيل الاهتزاز الخفيف Haptic Feedback"), tbl_cell_style), Paragraph(ar("منخفضة"), tbl_cell_style)],
        [Paragraph("RECORD_AUDIO (حظر صريح)", tbl_cell_en_style), Paragraph(ar("حماية الخصوصية المطلقة"), tbl_cell_style), Paragraph(ar("تم حظره برمجياً بـ tools:node='remove'"), tbl_cell_style), Paragraph(ar("آمن 100%"), tbl_cell_style)]
    ]

    perm_tbl = Table(perm_rows, colWidths=[130, 130, 200, 80])
    perm_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#00C030")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('BACKGROUND', (0,1), (-1,-1), colors.HexColor("#F8FAFC")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(perm_tbl)
    story.append(Spacer(1, 10))

    # --- SECTION 4: TECHNICAL ARCHITECTURE & DEPENDENCIES ---
    story.append(Paragraph(ar("4. البنية التقنية وحزمة المكتبات (Technical Architecture & Dependencies)"), h1_style))
    story.append(Paragraph(ar("• طبقة العرض والواجهات (Presentation Layer): تحتوي الشاشات والـ Glass Components التي تتفاعل مع المستخدم وتطبق تصميم Glassmorphism."), body_style))
    story.append(Paragraph(ar("• طبقة إدارة الحالة (State Management Layer): تُدار بواسطة حزمة provider عبر 4 مزودات رئيسية (PrayerTimesProvider, ThemeProvider, HomeLayoutProvider, TypographyProvider)."), body_style))
    story.append(Paragraph(ar("• طبقة الخدمات والذكاء (Services Layer): تشمل AIService (Gemini AI), AudioPlayerService (Background Audio), PermissionService, و UpdateService."), body_style))
    story.append(Paragraph(ar("• طبقة البيانات والمصادر (Data Layer): تشمل قواعد الأحاديث والأذكار المخزنة محلياً لضمان السرعة والعمل 100% بدون إنترنت."), body_style))

    story.append(Spacer(1, 15))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#00C030"), spaceAfter=10))
    story.append(Paragraph(ar("تم توثيق وتطهير هذا التقرير التقني والمعماري الشامل 100% لتطبيق \"أنا مسلم\" v1.0.7 لعام 2026. جميع الحقوق محفوظة لـ Mustafa Alhaj Mustafa."), ParagraphStyle('EndNote', fontName='ArabicArial', fontSize=9, leading=12, alignment=1, textColor=colors.HexColor("#64748B"))))

    doc.build(story, canvasmaker=CleanArchCanvas)
    print(f"Clean Architecture Report build successful: {filename}")

if __name__ == "__main__":
    out_pdf = "Ana_Muslim_Architecture_Report.pdf"
    build_pdf(out_pdf)
