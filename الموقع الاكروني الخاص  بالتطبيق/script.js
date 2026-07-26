document.addEventListener('DOMContentLoaded', () => {

    // --- Translations ---
    const translations = {
        ar: {
            app_name: "أنا مسلم",
            app_subtitle: "Ana Muslim",
            nav_features: "المميزات",
            nav_screenshots: "صور التطبيق",
            nav_faq: "الأسئلة",
            nav_download: "تحميل التطبيق",
            hero_badge: "✨ تحديث جديد 1.0.1",
            hero_title: "رفيقك اليومي \n في العبادة والحياة",
            hero_desc: "اكتشف تجربة إسلامية متكاملة تجمع بين الجمال والسهولة. قرآن، أذكار، وقبلة دقيقة في تطبيق صمم ليليق بك.",
            btn_download_apk: "تحميل APK",
            btn_video: "فيديو تعريفي",
            stat_downloads_num: "+100k",
            stat_downloads_label: "تحميل",
            stat_rating_num: "4.9",
            stat_rating_label: "تقييم المستخدمين",
            features_subtitle: "لماذا أنا مسلم؟",
            features_title: "كل ما تحتاجه في مكان واحد",
            feat_quran_title: "القرآن الكريم",
            feat_quran_desc: "المصحف كاملاً بخط واضح، مع تلاوات صوتية لأشهر القراء وإمكانية الحفظ والمتابعة.",
            feat_prayer_title: "مواقيت دقيقة",
            feat_prayer_desc: "تنبيهات دقيقة للأذان حسب موقعك، مع إمكانية تخصيص صوت المؤذن والمذهب الفقهي.",
            feat_qibla_title: "القبلة الذكية",
            feat_qibla_desc: "بوصلة متطورة تعتمد على المستشعرات والـ GPS لضمان دقة الاتجاه 100% أينما كنت.",
            feat_azkar_title: "أذكار المسلم",
            feat_azkar_desc: "حصن المسلم كاملاً، أذكار الصباح والمساء، وسبحة إلكترونية سلسة تساعدك على الذكر.",
            feat_calendar_title: "التقويم الهجري",
            feat_calendar_desc: "تابع الأيام البيض والمناسبات الدينية مع تقويم هجري وميلادي مدمج في واجهة واحدة.",
            feat_ai_title: "المساعد الذكي",
            feat_ai_desc: "استفسر عن مواقيت الصيام، اتجاه القبلة، أو ابحث في القرآن باستخدام الذكاء الاصطناعي.",
            screenshots_subtitle: "جولة سريعة",
            screenshots_title: "واجهة عصرية تريح العين",
            quote_verse: "\"أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ\"",
            quote_ref: "سورة الرعد - آية 28",
            download_title: "جاهز لتحسين يومك؟",
            download_desc: "قم بتحميل التطبيق الآن واستمتع بتجربة إبمانية فريدة.",
            btn_download_free: "تحميل APK مجاناً",
            btn_share: "مشاركة التطبيق",
            faq_title: "الأسئلة الشائعة",
            faq_q1: "هل التطبيق يعمل بدون إنترنت؟",
            faq_a1: "نعم، معظم الميزات الأساسية مثل قراءة القرآن، الأذكار، والمسبحة تعمل بكفاءة تامة دون الحاجة لاتصال بالإنترنت.",
            faq_q2: "هل التطبيق مجاني؟",
            faq_a2: "التطبيق مجاني 100% لوجه الله تعالى، ولا يحتوي على أي إعلانات مزعجة تعكر صفو العبادة.",
            faq_q3: "كيف أحدد اتجاه القبلة بدقة؟",
            faq_a3: "تأكد من تفعيل خدمة الموقع (GPS) في هاتفك، ثم قم بمعايرة البوصلة بتحريك الهاتف على شكل رقم 8 للحصول على أدق نتيجة.",
            footer_privacy: "سياسة الخصوصية",
            footer_contact: "تواصل معنا",
            footer_instagram: "تابعنا على إنستغرام",
            footer_copyright: "© 2025 – تطبيق أنا مسلم. جميع الحقوق محفوظة. Mustafa Alhaj Mustafa",
            footer_disclaimer: "هذا التطبيق لا يقدّم فتاوى شخصية، ويُنصح دائماً بالرجوع إلى أهل العلم."
        },
        en: {
            app_name: "Ana Muslim",
            app_subtitle: "Islamic App",
            nav_features: "Features",
            nav_screenshots: "Screenshots",
            nav_faq: "FAQ",
            nav_download: "Download",
            hero_badge: "✨ New Update 1.0.1",
            hero_title: "Your Daily Companion \n in Worship & Life",
            hero_desc: "Discover a complete Islamic experience combining beauty and ease. Quran, Azkar, and accurate Qibla in an app designed for you.",
            btn_download_apk: "Download APK",
            btn_video: "Intro Video",
            stat_downloads_num: "+100k",
            stat_downloads_label: "Downloads",
            stat_rating_num: "4.9",
            stat_rating_label: "User Rating",
            features_subtitle: "Why Ana Muslim?",
            features_title: "Everything You Need in One Place",
            feat_quran_title: "Noble Quran",
            feat_quran_desc: "Complete Quran with clear font, audio recitations by famous reciters, and progress tracking.",
            feat_prayer_title: "Accurate Times",
            feat_prayer_desc: "Precise Adhan notifications based on your location, with customizable Muazzin sounds and Fiqh schools.",
            feat_qibla_title: "Smart Qibla",
            feat_qibla_desc: "Advanced compass using sensors and GPS to ensure 100% accurate direction wherever you are.",
            feat_azkar_title: "Muslim Azkar",
            feat_azkar_desc: "Complete Hisn al-Muslim, Morning & Evening Azkar, and a smooth digital Tasbih.",
            feat_calendar_title: "Hijri Calendar",
            feat_calendar_desc: "Track White Days and religious occasions with a combined Hijri and Gregorian calendar.",
            feat_ai_title: "Smart Assistant",
            feat_ai_desc: "Ask about fasting times, Qibla direction, or search the Quran using AI.",
            screenshots_subtitle: "Quick Tour",
            screenshots_title: "Modern & Comfortable UI",
            quote_verse: "\"Unquestionably, by the remembrance of Allah hearts are assured.\"",
            quote_ref: "Surah Ar-Ra'd - Verse 28",
            download_title: "Ready to Improve Your Day?",
            download_desc: "Download the app now and enjoy a unique spiritual experience.",
            btn_download_free: "Download APK Free",
            btn_share: "Share App",
            faq_title: "Frequently Asked Questions",
            faq_q1: "Does the app work offline?",
            faq_a1: "Yes, most core features like Quran reading, Azkar, and Tasbih work perfectly without an internet connection.",
            faq_q2: "Is the app free?",
            faq_a2: "The app is 100% free for the sake of Allah, and contains no annoying ads to disturb your worship.",
            faq_q3: "How do I get accurate Qibla direction?",
            faq_a3: "Ensure GPS is enabled, then calibrate the compass by moving your phone in a figure-8 motion for the best result.",
            footer_privacy: "Privacy Policy",
            footer_contact: "Contact Us",
            footer_instagram: "Follow on Instagram",
            footer_copyright: "© 2025 – Ana Muslim App. All rights reserved. Mustafa Alhaj Mustafa",
            footer_disclaimer: "This app does not provide personal Fatwas; always consult scholars."
        },
        fr: {
            app_name: "Ana Muslim",
            app_subtitle: "Application Islamique",
            nav_features: "Fonctionnalités",
            nav_screenshots: "Captures",
            nav_faq: "FAQ",
            nav_download: "Télécharger",
            hero_badge: "✨ Nouvelle Mise à jour 1.0.1",
            hero_title: "Votre Compagnon \n Quotidien",
            hero_desc: "Découvrez une expérience islamique complète alliant beauté et facilité. Coran, Adhkar et Qibla précise dans une application conçue pour vous.",
            btn_download_apk: "Télécharger APK",
            btn_video: "Vidéo Intro",
            stat_downloads_num: "+100k",
            stat_downloads_label: "Téléchargements",
            stat_rating_num: "4.9",
            stat_rating_label: "Note Utilisateurs",
            features_subtitle: "Pourquoi Ana Muslim ?",
            features_title: "Tout ce dont vous avez besoin",
            feat_quran_title: "Noble Coran",
            feat_quran_desc: "Coran complet, police claire, récitations audio et suivi de progression.",
            feat_prayer_title: "Horaires Précis",
            feat_prayer_desc: "Notifications Adhan précises selon votre position, avec voix de Muazzin et écoles juridiques personnalisables.",
            feat_qibla_title: "Qibla Intelligente",
            feat_qibla_desc: "Boussole avancée utilisant capteurs et GPS pour une précision de 100% partout.",
            feat_azkar_title: "Adhkar Musulman",
            feat_azkar_desc: "Hisn al-Muslim complet, Adhkar du matin/soir et Tasbih numérique fluide.",
            feat_calendar_title: "Calendrier Hégirien",
            feat_calendar_desc: "Suivez les jours blancs et occasions religieuses avec un calendrier Hégirien/Grégorien intégré.",
            feat_ai_title: "Assistant Intelligent",
            feat_ai_desc: "Demandez les heures de jeûne, la Qibla ou recherchez dans le Coran via l'IA.",
            screenshots_subtitle: "Tour Rapide",
            screenshots_title: "Interface Moderne & Confortable",
            quote_verse: "\"N'est-ce point par l'évocation d'Allah que se tranquillisent les cœurs ?\"",
            quote_ref: "Sourate Ar-Ra'd - Verset 28",
            download_title: "Prêt à améliorer votre journée ?",
            download_desc: "Téléchargez l'application maintenant et vivez une expérience spirituelle unique.",
            btn_download_free: "Télécharger Gratuitement",
            btn_share: "Partager l'App",
            faq_title: "Questions Fréquentes",
            faq_q1: "L'application fonctionne-t-elle hors ligne ?",
            faq_a1: "Oui, la plupart des fonctions (Coran, Adhkar, Tasbih) fonctionnent parfaitement sans internet.",
            faq_q2: "L'application est-elle payante ?",
            faq_a2: "L'application est 100% gratuite pour la face d'Allah, sans publicités gênantes.",
            faq_q3: "Comment avoir une Qibla précise ?",
            faq_a3: "Activez le GPS et calibrez la boussole en faisant un 8 avec votre téléphone pour le meilleur résultat.",
            footer_privacy: "Politique de Confidentialité",
            footer_contact: "Contactez-nous",
            footer_instagram: "Suivre sur Instagram",
            footer_copyright: "© 2025 – App Ana Muslim. Tous droits réservés. Mustafa Alhaj Mustafa",
            footer_disclaimer: "Cette application ne fournit pas de Fatwas personnelles ; consultez les savants."
        }
    };

    const setLanguage = (lang) => {
        // Update html attrs
        document.documentElement.lang = lang;
        document.documentElement.dir = (lang === 'ar') ? 'rtl' : 'ltr';

        // Update elements
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (translations[lang][key]) {
                // If it's the hero title, we might need to update ScrambleText if initialized
                if (el.classList.contains('hero-title')) {
                    // handled separately via ScrambleText updates or reload
                    // But we set innerHTML for static view
                    el.innerHTML = translations[lang][key].replace('\n', '<br>');
                } else {
                    el.innerText = translations[lang][key];
                }
            }
        });

        // Save preference
        localStorage.setItem('ana_muslim_lang', lang);

        // Update selector value
        const selector = document.getElementById('language-selector');
        if (selector) selector.value = lang;
    };

    // Initialize Language
    const savedLang = localStorage.getItem('ana_muslim_lang') || 'ar';
    const langSelect = document.getElementById('language-selector');
    if (langSelect) {
        langSelect.addEventListener('change', (e) => {
            setLanguage(e.target.value);
            // Re-trigger scramble text if it's the hero title
            const heroTitle = document.querySelector('.hero-title');
            if (heroTitle && typeof ScrambleText !== 'undefined') {
                // We need to access the scramble instance if possible, or just create new one
                // Simpler: Just reload scrambler or just let the setText update it
                // Since ScrambleText class is below, we might need to hoist or wait.
                // Actually, ScrambleText is defined below. We can't access it easily here unless we move the class up or use a global.
                // Let's rely on the fact that setLanguage updates innerText.
                // However, ScrambleText in this code overwrites it on load.
                // We should update the `finalHeader` inside the onload.
            }
            window.location.reload(); // Easiest way to ensure all JS effects (Scramble, etc) align with new text structure without complex state management
        });
        // Set initial value in selector without triggering reload
        langSelect.value = savedLang;
        setLanguage(savedLang);
    }


    // --- Preloader & Entry ---
    const preloader = document.getElementById('preloader');
    if (preloader) {
        const removePreloader = () => {
            if (preloader.style.opacity === '0') return; // Already done
            setTimeout(() => {
                preloader.style.opacity = '0';
                preloader.style.visibility = 'hidden';

                // Trigger entry animations
                const header = document.querySelector('.header');
                if (header) header.classList.remove('initial-hidden');
                document.querySelectorAll('.hero .reveal-text').forEach(el => el.classList.add('active'));

                // Start Text Scramble
                const heroTitle = document.querySelector('.hero-title');
                if (heroTitle && typeof ScrambleText !== 'undefined') {
                    const currentLang = localStorage.getItem('ana_muslim_lang') || 'ar';
                    const text = translations[currentLang].hero_title; // Use translated text
                    new ScrambleText(heroTitle, text).start();
                }
            }, 500); // Shorter delay for snappier feel
        };

        window.addEventListener('load', removePreloader);

        // Safety fallback: Force show after 4 seconds if load hangs
        setTimeout(removePreloader, 4000);
    }

    // --- 3D Globe / Network Canvas ---
    const canvas = document.getElementById('bg-canvas');
    if (canvas) {
        const ctx = canvas.getContext('2d');
        let width, height;

        // Globe Config
        const GLOBE_RADIUS = 400;
        let DOTS_AMOUNT = 800; // Default for desktop
        const DOT_RADIUS = 1.5;
        let fieldOfView;

        class Dot3D {
            constructor(x, y, z) {
                this.x = x; this.y = y; this.z = z;
                this.xProjected = 0; this.yProjected = 0;
                this.scaleProjected = 0;
            }
            project() {
                this.scaleProjected = fieldOfView / (fieldOfView + this.z);
                this.xProjected = (this.x * this.scaleProjected) + width / 2;
                this.yProjected = (this.y * this.scaleProjected) + height / 2;
            }
            draw() {
                this.project();
                let alpha = (this.z + GLOBE_RADIUS) / (2 * GLOBE_RADIUS);
                alpha = 1 - Math.min(Math.max(alpha, 0), 1);
                if (alpha < 0.1) alpha = 0.1;

                ctx.globalAlpha = alpha;
                if (this.x > 0) ctx.fillStyle = '#0FC2C0';
                else ctx.fillStyle = '#A855F7';

                ctx.beginPath();
                ctx.arc(this.xProjected, this.yProjected, DOT_RADIUS * this.scaleProjected, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        let dots = [];

        function initGlobe() {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
            fieldOfView = width * 0.8;
            dots = [];

            // Performance Optimization: Reduce dots on mobile
            if (window.innerWidth < 768) {
                DOTS_AMOUNT = 250; // Vastly reduce for mobile
            } else {
                DOTS_AMOUNT = 800;
            }

            for (let i = 0; i < DOTS_AMOUNT; i++) {
                const theta = Math.random() * 2 * Math.PI;
                const phi = Math.acos((Math.random() * 2) - 1);

                const x = GLOBE_RADIUS * Math.sin(phi) * Math.cos(theta);
                const y = GLOBE_RADIUS * Math.sin(phi) * Math.sin(theta);
                const z = GLOBE_RADIUS * Math.cos(phi);

                dots.push(new Dot3D(x, y, z));
            }
        }

        let rotationSpeed = 0.001;

        window.addEventListener('mousemove', e => {
            // Accelerate rotation slightly on mouse move
            rotationSpeed = 0.005;
            clearTimeout(window.rotationTimer);
            window.rotationTimer = setTimeout(() => { rotationSpeed = 0.001; }, 500);

            // CSS Mouse tracking for cards
            document.querySelectorAll('.feature-card, .holo-card').forEach(card => {
                const rect = card.getBoundingClientRect();
                card.style.setProperty('--mouse-x', `${e.clientX - rect.left}px`);
                card.style.setProperty('--mouse-y', `${e.clientY - rect.top}px`);
            });
        });

        function animateGlobe() {
            ctx.clearRect(0, 0, width, height);

            dots.forEach(dot => {
                // Rotate Y
                const cosRot = Math.cos(rotationSpeed);
                const sinRot = Math.sin(rotationSpeed);
                const x1 = dot.x * cosRot - dot.z * sinRot;
                const z1 = dot.z * cosRot + dot.x * sinRot;
                dot.x = x1; dot.z = z1;

                // Rotate X (Slight constant tilt)
                const angleX = 0.0005;
                const cosX = Math.cos(angleX);
                const sinX = Math.sin(angleX);
                const y2 = dot.y * cosX - dot.z * sinX;
                const z2 = dot.z * cosX + dot.y * sinX;
                dot.y = y2; dot.z = z2;

                dot.draw();
            });

            requestAnimationFrame(animateGlobe);
        }

        window.addEventListener('resize', initGlobe);
        initGlobe();
        animateGlobe();
    }


    // --- Text Scramble Class ---
    class ScrambleText {
        constructor(el, finalHeader) {
            this.el = el;
            this.finalHeader = finalHeader || el.innerText;
            this.chars = '!<>-_\\/[]{}—=+*^?#________';
            this.queue = [];
            this.frame = 0;
            this.update = this.update.bind(this);
            this.resolve = this.resolve.bind(this);
            this.frameRequest = null;
        }

        setText(newText) {
            const oldText = this.el.innerText;
            const length = Math.max(oldText.length, newText.length);
            const promise = new Promise((resolve) => this.resolve = resolve);
            this.queue = [];
            for (let i = 0; i < length; i++) {
                const from = oldText[i] || '';
                const to = newText[i] || '';
                const start = Math.floor(Math.random() * 40);
                const end = start + Math.floor(Math.random() * 40);
                this.queue.push({ from, to, start, end });
            }
            if (this.frameRequest) cancelAnimationFrame(this.frameRequest);
            this.frame = 0;
            this.update();
            return promise;
        }

        update() {
            let output = '';
            let complete = 0;
            for (let i = 0, n = this.queue.length; i < n; i++) {
                let { from, to, start, end, char } = this.queue[i];
                if (this.frame >= end) {
                    complete++;
                    output += to;
                } else if (this.frame >= start) {
                    if (!char || Math.random() < 0.28) {
                        char = this.chars[Math.floor(Math.random() * this.chars.length)];
                        this.queue[i].char = char;
                    }
                    output += `<span class="scramble-text" style="color:var(--primary-color)">${char}</span>`;
                } else {
                    output += from;
                }
            }
            this.el.innerHTML = output;
            if (complete === this.queue.length) {
                // Done
            } else {
                this.frameRequest = requestAnimationFrame(this.update);
                this.frame++;
            }
        }

        start() {
            this.setText(this.finalHeader);
        }
    }

    // --- Scroll & Reveal ---
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('active');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

    // Navbar scroll
    const header = document.querySelector('.header');
    if (header) {
        window.addEventListener('scroll', () => { header.classList.toggle('scrolled', window.scrollY > 50); });
    }

    // FAQ
    // FAQ
    document.querySelectorAll('.accordion-header').forEach(header => {
        header.addEventListener('click', () => {
            const content = header.nextElementSibling;
            const isOpen = header.classList.contains('active');

            // Close others
            document.querySelectorAll('.accordion-header').forEach(h => {
                if (h !== header && h.classList.contains('active')) {
                    h.classList.remove('active');
                    h.nextElementSibling.style.maxHeight = null;
                    h.nextElementSibling.style.opacity = '0'; // Ensure opacity transition
                }
            });

            // Toggle current
            header.classList.toggle('active');
            if (!isOpen) {
                // Opening
                content.style.opacity = '1';
                // Use small timeout or requestAnimationFrame to ensure display transition
                requestAnimationFrame(() => {
                    content.style.maxHeight = (content.scrollHeight + 20) + "px"; // Add buffer
                });
            } else {
                // Closing
                content.style.maxHeight = null;
                content.style.opacity = '0';
            }
        });
    });

    // --- 3D Tilt for Cards (Vanilla JS) ---
    const tiltCards = document.querySelectorAll('[data-tilt], .feature-card, .holo-card');
    tiltCards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            // Calculate rotation (max 10deg)
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;

            const rotateX = ((y - centerY) / centerY) * -5;
            const rotateY = ((x - centerX) / centerX) * 5;

            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.02)`;
        });

        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale(1)';
        });
    });

    // --- Custom Cursor Logic ---
    const cursorDot = document.querySelector('[data-cursor-dot]');
    const cursorOutline = document.querySelector('[data-cursor-outline]');

    window.addEventListener('mousemove', function (e) {
        const posX = e.clientX;
        const posY = e.clientY;

        // Dot follows instantly
        cursorDot.style.left = `${posX}px`;
        cursorDot.style.top = `${posY}px`;

        // Outline follows with lag
        cursorOutline.animate({
            left: `${posX}px`,
            top: `${posY}px`
        }, { duration: 500, fill: "forwards" });
    });

    // Expand cursor on hoverable elements
    const hoverables = document.querySelectorAll('a, button, .feature-card, .holo-card, .accordion-header');
    hoverables.forEach(el => {
        el.addEventListener('mouseenter', () => {
            cursorOutline.style.width = '60px'; // Expand
            cursorOutline.style.height = '60px';
            cursorOutline.style.backgroundColor = 'rgba(255,255,255,0.1)';
        });
        el.addEventListener('mouseleave', () => {
            cursorOutline.style.width = '40px'; // Shrink
            cursorOutline.style.height = '40px';
            cursorOutline.style.backgroundColor = 'transparent';
        });
    });


    // --- Mobile Menu Logic ---
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const closeMenuBtn = document.querySelector('.close-menu-btn');
    const mobileMenu = document.querySelector('.mobile-menu');
    const mobileLinks = document.querySelectorAll('.mobile-nav-links a');

    if (mobileMenuBtn && mobileMenu) {
        // Open
        mobileMenuBtn.addEventListener('click', () => {
            mobileMenu.classList.add('active');
            document.body.style.overflow = 'hidden'; // Prevent scrolling
        });

        // Close
        const closeMenu = () => {
            mobileMenu.classList.remove('active');
            document.body.style.overflow = '';
        };

        if (closeMenuBtn) closeMenuBtn.addEventListener('click', closeMenu);

        // Close on link click
        mobileLinks.forEach(link => {
            link.addEventListener('click', closeMenu);
        });
    }

});

// --- Global iOS IPA Modal Helper Functions ---
function openIosModal(e) {
    if (e) e.preventDefault();
    const modal = document.getElementById('ios-modal');
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeIosModal() {
    const modal = document.getElementById('ios-modal');
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }
}

function closeAnnouncementBar() {
    const bar = document.getElementById('announcement-bar');
    if (bar) {
        bar.style.display = 'none';
    }
}

// Close on outside click & ESC key
document.addEventListener('click', (e) => {
    const modal = document.getElementById('ios-modal');
    if (modal && e.target === modal) {
        closeIosModal();
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeIosModal();
    }
});

