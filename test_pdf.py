import asyncio
import os
from playwright.async_api import async_playwright

html_content = """<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="UTF-8">
<style>
body { font-family: 'Segoe UI', Tahoma, Arial, sans-serif; padding: 40px; }
h1 { color: #0d5c3a; }
</style>
</head>
<body>
<h1>اختبار تقرير PDF باللغة العربية</h1>
<p>هذا اختبار لتوليد ملف PDF عالي الجودة يدعم اللغة العربية بشكل كامل مع الاتجاه من اليمين إلى اليسار (RTL).</p>
</body>
</html>"""

async def main():
    async with async_playwright() as p:
        try:
            browser = await p.chromium.launch()
            page = await browser.new_page()
            await page.set_content(html_content)
            await page.pdf(path="test_playwright.pdf", format="A4", print_background=True)
            await browser.close()
            print("SUCCESS with Playwright Chromium!")
        except Exception as e:
            print("Playwright error:", e)

if __name__ == "__main__":
    asyncio.run(main())
