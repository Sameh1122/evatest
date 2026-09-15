import os
import sys
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

def set_cell_background(cell, fill_hex):
    tcPr = cell._element.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def create_docx(filename):
    doc = Document()
    
    # Margins
    for section in doc.sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)

    # Palette
    PRIMARY = RGBColor(16, 185, 129)     # Emerald
    SECONDARY = RGBColor(14, 165, 233)   # Cyan
    DARK_BG = RGBColor(15, 23, 42)       # Dark Slate
    TEXT_DARK = RGBColor(30, 41, 59)     # Text Slate
    TEXT_MUTED = RGBColor(100, 116, 139)

    # Styles
    styles = doc.styles
    normal_style = styles['Normal']
    normal_style.font.name = 'Calibri'
    normal_style.font.size = Pt(11)
    normal_style.font.color.rgb = TEXT_DARK

    # Title Banner
    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    r_brand = p_title.add_run("LIMITLESS NATURALS BY EVA PHARMA\n")
    r_brand.font.size = Pt(13)
    r_brand.font.bold = True
    r_brand.font.color.rgb = PRIMARY
    
    r_main = p_title.add_run("COMMERCIAL & TECHNICAL FINANCIAL PROPOSAL\n")
    r_main.font.size = Pt(20)
    r_main.font.bold = True
    r_main.font.color.rgb = DARK_BG
    
    r_sub = p_title.add_run("Cross-Platform Mobile Application (iOS & Android) & Full-Stack Web Platform\nDelivery & Operational Cost Breakdowns | 2M Clients & 2,000 Concurrent Sizing")
    r_sub.font.size = Pt(11)
    r_sub.font.italic = True
    r_sub.font.color.rgb = TEXT_MUTED

    doc.add_paragraph().paragraph_format.space_after = Pt(10)

    def add_h(text, level=1):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(6)
        run = p.add_run(text)
        run.font.bold = True
        if level == 1:
            run.font.size = Pt(15)
            run.font.color.rgb = PRIMARY
        elif level == 2:
            run.font.size = Pt(12.5)
            run.font.color.rgb = DARK_BG
        else:
            run.font.size = Pt(11)
            run.font.color.rgb = SECONDARY
        return p

    # 1. Executive Summary & Financial Overview
    add_h("1. Executive Summary & Financial Overview", level=1)
    doc.add_paragraph(
        "This proposal provides the comprehensive financial pricing model, infrastructure specifications, scrum team rate guidance, "
        "and complete business feature architecture for the Limitless Naturals Mobile Application (iOS & Android) and Web E-Commerce Platform. "
        "The pricing model cleanly distinguishes between the Project Delivery Cost (turnkey software engineering spread across 6 milestones) "
        "and the Monthly Operational Infrastructure Costs (AWS hosting, SMS, Email, and Payment Gateway transactions)."
    )

    # 2. Business Feature Matrix
    add_h("2. Complete Business Feature Matrix", level=1)
    doc.add_paragraph(
        "The application architecture encompasses four distinct business portals tailored for client engagement, marketing automation, and logistics:"
    )

    biz_features = [
        ("A. Client Mobile App & Web Storefront (iOS & Android)", [
            "Personalized Health Profile Matrix: Chronic disease input (Hypertension, Kidney Disease, Allergies, Medication notes).",
            "AI Supplement Recommendation Engine: Algorithmic matching of patient health profiles against active ingredient dosages.",
            "Medical Contraindication Safety Engine: Automated safety checks flagging dangerous interactions (e.g., Ginseng in severe hypertension).",
            "Hydration & Electrolyte Need Calculator: Dynamic daily water/electrolyte calculation based on body weight and activity level.",
            "Limitless Product Catalog: Multi-category browsing (Daily Wellness, Immune Defense, Hydration) with full ingredient breakdowns.",
            "E-Commerce Cart & Checkout: Promo code validation, address management, Credit Card / Cash-on-Delivery (COD).",
            "Live Order Status Stepper: 4-stage delivery tracking (Placed -> Processing -> Out for Delivery -> Delivered)."
        ]),
        ("B. Admin Portal & Multi-Channel Notification Center", [
            "Multi-Channel Broadcast Engine: Send campaigns via Android Push, iOS Push, Transactional Email, and SMS.",
            "Target Audience Segmentation: Filter recipients by chronic conditions, order history, or abandoned cart status.",
            "Automated AI Triggers & Discounts: Rule engine for automated AI health recommendations and low-stock promo broadcasts.",
            "Product Catalog Management: Full CRUD capability to modify SKUs, prices, stock levels, contraindications, and imagery.",
            "Order Management & Payment Toggling: Real-time order fulfillment control and payment status toggle ('Paid' vs 'Pending').",
            "Executive Sales & Financial Dashboard: Revenue analytics, top-performing SKUs, conversion funnel, and distributor metrics."
        ]),
        ("C. Distributor Logistics & Warehouse Portal", [
            "Driver Delivery Queue: Dedicated dispatch view for assigned couriers with express routing details.",
            "Order Logistics Progression: Stepper updating order state from Pending -> Picked Up -> Out for Delivery -> Delivered.",
            "Warehouse Capacity Gauges: Live storage utilization tracking with automated low-stock reorder warnings."
        ]),
        ("D. Visitor / Public Storefront", [
            "Full access to official Limitless catalog, health tag filters, ingredient disclosures, and quick demo registration prompts."
        ])
    ]

    for title, items in biz_features:
        add_h(title, level=2)
        for item in items:
            p = doc.add_paragraph(style='List Bullet')
            p.add_run(item)

    # 3. Agile Scrum Team Monthly Cost Guidance
    add_h("3. Agile Scrum Team Resource Pricing Guidance", level=1)
    doc.add_paragraph(
        "The project is powered by an 11-member dedicated Scrum team operating across an 8-month development cycle. "
        "Below is the monthly rate card guidance per role:"
    )

    table_team = doc.add_table(rows=1, cols=4)
    table_team.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr = table_team.rows[0].cells
    for i, t in enumerate(["Scrum Role", "Headcount", "Monthly Rate per Specialist (EGP)", "Total Monthly Role Cost (EGP)"]):
        hdr[i].text = t
        set_cell_background(hdr[i], "0F172A")
        hdr[i].paragraphs[0].runs[0].font.bold = True
        hdr[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    team_cost_rows = [
        ("Product Owner (PO)", "1x", "80,000 EGP", "80,000 EGP"),
        ("Scrum Master (SM)", "1x", "60,000 EGP", "60,000 EGP"),
        ("UI/UX Designer", "1x", "40,000 EGP", "40,000 EGP"),
        ("Mobile Developers (Flutter iOS/Android)", "2x", "50,000 EGP", "100,000 EGP"),
        ("Backend Developers (Node.js/Postgres)", "3x", "50,000 EGP", "150,000 EGP"),
        ("DevOps Engineer", "1x", "50,000 EGP", "50,000 EGP"),
        ("QC / QA Engineers", "2x", "50,000 EGP", "100,000 EGP"),
        ("TOTAL MONTHLY SCRUM TEAM COST", "11 Members", "---", "580,000 EGP / month")
    ]

    for row in team_cost_rows:
        cells = table_team.add_row().cells
        is_total = "TOTAL" in row[0]
        for i, val in enumerate(row):
            cells[i].text = val
            set_cell_background(cells[i], "10B981" if is_total else ("F8FAFC" if i % 2 == 0 else "FFFFFF"))
            if is_total:
                cells[i].paragraphs[0].runs[0].font.bold = True
                cells[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    p_sum = doc.add_paragraph()
    p_sum.paragraph_format.space_before = Pt(8)
    r_tot = p_sum.add_run("Total 8-Month Project Delivery Budget = 580,000 EGP/month x 8 Months = 4,640,000 EGP Total")
    r_tot.font.bold = True
    r_tot.font.size = Pt(11.5)
    r_tot.font.color.rgb = PRIMARY

    # 4. Delivery Cost per Milestone
    add_h("4. Delivery Cost Milestone Breakdown (Project Budget: 4,640,000 EGP)", level=1)
    doc.add_paragraph(
        "Project delivery pricing (4,640,000 EGP total) is structured into 6 milestone payments tied directly to deliverable verification:"
    )

    table_milestone = doc.add_table(rows=1, cols=5)
    table_milestone.alignment = WD_TABLE_ALIGNMENT.CENTER
    m_hdr = table_milestone.rows[0].cells
    for i, t in enumerate(["Milestone Phase", "Timeline", "Payment %", "Milestone Amount (EGP)", "Trigger Deliverable Condition"]):
        m_hdr[i].text = t
        set_cell_background(m_hdr[i], "0F172A")
        m_hdr[i].paragraphs[0].runs[0].font.bold = True
        m_hdr[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    m_rows = [
        ("Milestone 1: Kickoff & SRS", "Month 1", "15%", "696,000 EGP", "SRS document, Figma UI/UX designs, and cloud staging setup"),
        ("Milestone 2: Core Dev Phase A", "Months 2–3", "25%", "1,160,000 EGP", "Sprints 1–3: Mobile Client App, Auth, AI Engine & Catalog"),
        ("Milestone 3: Core Dev Phase B", "Month 4", "25%", "1,160,000 EGP", "Sprints 4–6: Admin Notification Center, Checkout & Distributor App"),
        ("Milestone 4: SIT Testing", "Month 5", "15%", "696,000 EGP", "SIT testing, security audit, and 2,000 concurrent load stress test"),
        ("Milestone 5: UAT Testing", "Months 6–7", "10%", "464,000 EGP", "Client UAT sign-off and completion of user feedback punch list"),
        ("Milestone 6: Go-Live & Handover", "Month 8", "10%", "464,000 EGP", "App Store & Google Play deployment, production cutover & hypercare"),
        ("TOTAL DELIVERY COST", "8 Months", "100%", "4,640,000 EGP", "Complete Turnkey System Handover")
    ]

    for row in m_rows:
        cells = table_milestone.add_row().cells
        is_total = "TOTAL" in row[0]
        for i, val in enumerate(row):
            cells[i].text = val
            set_cell_background(cells[i], "10B981" if is_total else ("F8FAFC" if i % 2 == 0 else "FFFFFF"))
            if is_total:
                cells[i].paragraphs[0].runs[0].font.bold = True
                cells[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    # 5. Infrastructure Operational Costs
    add_h("5. Monthly Infrastructure Operational Costs (2M Clients / 2K Concurrent)", level=1)
    doc.add_paragraph(
        "Below are the monthly running costs in both EGP and USD required to maintain the cloud production environment and third-party APIs:"
    )

    table_op = doc.add_table(rows=1, cols=4)
    table_op.alignment = WD_TABLE_ALIGNMENT.CENTER
    op_hdr = table_op.rows[0].cells
    for i, t in enumerate(["Operational Component", "Provider / Spec", "Est. Monthly Cost (USD)", "Est. Monthly Cost (EGP @ 50 EGP/$)"]):
        op_hdr[i].text = t
        set_cell_background(op_hdr[i], "0F172A")
        op_hdr[i].paragraphs[0].runs[0].font.bold = True
        op_hdr[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    op_rows = [
        ("AWS Infrastructure", "ALB, EKS (3-10 nodes), Aurora Postgres, Redis, S3, CloudFront", "~$1,100 / mo", "~55,000 EGP / month"),
        ("Firebase FCM Push", "Android & iOS Push Notifications, Crashlytics, Analytics", "FREE", "0 EGP"),
        ("Transactional Email", "SendGrid / AWS SES (500,000 emails/mo)", "~$60 / mo", "~3,000 EGP / month"),
        ("SMS Gateway", "Twilio / Local Telecom (~20,000 SMS/mo)", "~$300 / mo", "~15,000 EGP / month"),
        ("Payment Gateways", "Stripe / Fawry / PayMob / PayFort", "2.2% - 2.75% + $0.15/tx", "Usage-Based Transactional"),
        ("Developer Publishers", "Apple Developer ($99/yr) + Google Play ($25 one-time)", "~$10 / mo avg", "~500 EGP / month"),
        ("TOTAL OPERATIONAL RUNNING COST", "Cloud + Third-Party Services", "~$1,470 / month", "~73,500 EGP / month")
    ]

    for row in op_rows:
        cells = table_op.add_row().cells
        is_total = "TOTAL" in row[0]
        for i, val in enumerate(row):
            cells[i].text = val
            set_cell_background(cells[i], "0F172A" if is_total else ("F8FAFC" if i % 2 == 0 else "FFFFFF"))
            if is_total:
                cells[i].paragraphs[0].runs[0].font.bold = True
                cells[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    doc.save(filename)
    print(f"DOCX created: {filename}")

def create_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36
    )

    styles = getSampleStyleSheet()
    PRIMARY = colors.HexColor("#10B981")
    DARK_BG = colors.HexColor("#0F172A")
    TEXT_DARK = colors.HexColor("#1E293B")

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=DARK_BG,
        alignment=1,
        spaceAfter=12
    )

    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor("#64748B"),
        alignment=1,
        spaceAfter=15
    )

    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=PRIMARY,
        spaceBefore=12,
        spaceAfter=6
    )

    h2_style = ParagraphStyle(
        'H2',
        parent=styles['Heading3'],
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=14,
        textColor=DARK_BG,
        spaceBefore=8,
        spaceAfter=3
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['BodyText'],
        fontName='Helvetica',
        fontSize=9,
        leading=12.5,
        textColor=TEXT_DARK,
        spaceAfter=6
    )

    table_cell_header = ParagraphStyle(
        'TH',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.white
    )

    table_cell_body = ParagraphStyle(
        'TD',
        fontName='Helvetica',
        fontSize=7.5,
        leading=9.5,
        textColor=TEXT_DARK
    )

    story = []

    story.append(Paragraph("LIMITLESS NATURALS BY EVA PHARMA", ParagraphStyle('BBrand', fontName='Helvetica-Bold', fontSize=11, leading=13, textColor=PRIMARY, alignment=1)))
    story.append(Paragraph("COMMERCIAL & TECHNICAL FINANCIAL PROPOSAL", title_style))
    story.append(Paragraph("Cross-Platform Mobile Application (iOS & Android) & Full-Stack Web Platform<br/>Delivery & Operational Costs | 2M Clients & 2,000 Concurrent Sizing", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=PRIMARY, spaceBefore=4, spaceAfter=12))

    # 1. Executive Summary
    story.append(Paragraph("1. Executive Summary & Financial Overview", h1_style))
    story.append(Paragraph(
        "This proposal provides the comprehensive financial pricing model, cloud infrastructure specifications, "
        "scrum team resource guidance, and complete business feature architecture for Limitless Naturals by Eva Pharma. "
        "The model separates Project Delivery Cost (4,640,000 EGP total spread over 6 milestone payments) from Monthly Operational Running Costs (~73,500 EGP / month).",
        body_style
    ))

    # 2. Business Features
    story.append(Paragraph("2. Complete Business Feature Matrix", h1_style))
    f_text = (
        "<b>• Client Mobile App & Web:</b> Personal health profile & chronic disease matrix (Hypertension, Kidney Disease), AI supplement recommender, contraindication screening engine, hydration calculator, catalog browsing, promo codes, cart, credit card/COD checkout, live 4-stage order tracker.<br/>"
        "<b>• Admin Portal & Notification Center:</b> Multi-channel campaign broadcast (Android/iOS Push, Email, SMS), target audience segmentation, automated AI health recommendation triggers, product catalog CRUD, payment status toggle ('Paid'/'Pending'), revenue & fulfillment analytics.<br/>"
        "<b>• Distributor Logistics App:</b> Driver delivery dispatch queue, order status progression stepper (Pending -> Picked Up -> Out for Delivery -> Delivered), warehouse capacity gauges & low stock reorder alerts."
    )
    story.append(Paragraph(f_text, body_style))
    story.append(Spacer(1, 8))

    # 3. Team Rate Guidance
    story.append(Paragraph("3. Agile Scrum Team Resource Guidance (11 Members)", h1_style))
    t_data = [
        [Paragraph("Scrum Role", table_cell_header), Paragraph("Headcount", table_cell_header), Paragraph("Monthly Rate / Specialist", table_cell_header), Paragraph("Total Monthly Role Cost", table_cell_header)],
        [Paragraph("Product Owner (PO)", table_cell_body), Paragraph("1x", table_cell_body), Paragraph("80,000 EGP", table_cell_body), Paragraph("80,000 EGP", table_cell_body)],
        [Paragraph("Scrum Master (SM)", table_cell_body), Paragraph("1x", table_cell_body), Paragraph("60,000 EGP", table_cell_body), Paragraph("60,000 EGP", table_cell_body)],
        [Paragraph("UI/UX Designer", table_cell_body), Paragraph("1x", table_cell_body), Paragraph("40,000 EGP", table_cell_body), Paragraph("40,000 EGP", table_cell_body)],
        [Paragraph("Mobile Developers (Flutter)", table_cell_body), Paragraph("2x", table_cell_body), Paragraph("50,000 EGP", table_cell_body), Paragraph("100,000 EGP", table_cell_body)],
        [Paragraph("Backend Developers (Node.js)", table_cell_body), Paragraph("3x", table_cell_body), Paragraph("50,000 EGP", table_cell_body), Paragraph("150,000 EGP", table_cell_body)],
        [Paragraph("DevOps Engineer", table_cell_body), Paragraph("1x", table_cell_body), Paragraph("50,000 EGP", table_cell_body), Paragraph("50,000 EGP", table_cell_body)],
        [Paragraph("QC / QA Engineers", table_cell_body), Paragraph("2x", table_cell_body), Paragraph("50,000 EGP", table_cell_body), Paragraph("100,000 EGP", table_cell_body)],
        [Paragraph("TOTAL MONTHLY SCRUM TEAM COST", table_cell_header), Paragraph("11 Members", table_cell_header), Paragraph("---", table_cell_header), Paragraph("580,000 EGP / mo", table_cell_header)]
    ]
    t_team_pdf = Table(t_data, colWidths=[160, 70, 140, 160])
    t_team_pdf.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('BACKGROUND', (0,-1), (-1,-1), PRIMARY),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(t_team_pdf)
    story.append(Spacer(1, 8))

    # 4. Delivery Cost per Milestone
    story.append(Paragraph("4. Delivery Cost Milestone Breakdown (Total: 4,640,000 EGP)", h1_style))
    m_data = [
        [Paragraph("Milestone Phase", table_cell_header), Paragraph("Timeline", table_cell_header), Paragraph("%", table_cell_header), Paragraph("Amount (EGP)", table_cell_header), Paragraph("Trigger Condition / Deliverable", table_cell_header)],
        [Paragraph("M1: Kickoff & SRS", table_cell_body), Paragraph("Month 1", table_cell_body), Paragraph("15%", table_cell_body), Paragraph("696,000 EGP", table_cell_body), Paragraph("SRS & Figma UI/UX approval", table_cell_body)],
        [Paragraph("M2: Core Dev Phase A", table_cell_body), Paragraph("Months 2–3", table_cell_body), Paragraph("25%", table_cell_body), Paragraph("1,160,000 EGP", table_cell_body), Paragraph("Sprints 1–3: Client App & AI Engine", table_cell_body)],
        [Paragraph("M3: Core Dev Phase B", table_cell_body), Paragraph("Month 4", table_cell_body), Paragraph("25%", table_cell_body), Paragraph("1,160,000 EGP", table_cell_body), Paragraph("Sprints 4–6: Admin Notifications & Logistics", table_cell_body)],
        [Paragraph("M4: SIT Testing", table_cell_body), Paragraph("Month 5", table_cell_body), Paragraph("15%", table_cell_body), Paragraph("696,000 EGP", table_cell_body), Paragraph("SIT & 2K concurrent stress test", table_cell_body)],
        [Paragraph("M5: UAT Testing", table_cell_body), Paragraph("Months 6–7", table_cell_body), Paragraph("10%", table_cell_body), Paragraph("464,000 EGP", table_cell_body), Paragraph("Client UAT sign-off & feedback resolution", table_cell_body)],
        [Paragraph("M6: Go-Live & Support", table_cell_body), Paragraph("Month 8", table_cell_body), Paragraph("10%", table_cell_body), Paragraph("464,000 EGP", table_cell_body), Paragraph("App Store / Play Store launch & hypercare", table_cell_body)],
        [Paragraph("TOTAL DELIVERY COST", table_cell_header), Paragraph("8 Months", table_cell_header), Paragraph("100%", table_cell_header), Paragraph("4,640,000 EGP", table_cell_header), Paragraph("Complete Turnkey System Handover", table_cell_header)]
    ]
    t_m_pdf = Table(m_data, colWidths=[100, 60, 35, 95, 240])
    t_m_pdf.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('BACKGROUND', (0,-1), (-1,-1), PRIMARY),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(t_m_pdf)
    story.append(Spacer(1, 8))

    # 5. Infrastructure Operational Costs
    story.append(Paragraph("5. Monthly Operational Costs (2M Users / 2K Concurrent)", h1_style))
    op_data = [
        [Paragraph("Operational Component", table_cell_header), Paragraph("Provider / Spec", table_cell_header), Paragraph("Est. Monthly (USD)", table_cell_header), Paragraph("Est. Monthly (EGP @ 50 EGP/$)", table_cell_header)],
        [Paragraph("AWS Cloud Infrastructure", table_cell_body), Paragraph("ALB, EKS (3-10 nodes), Postgres, Redis, S3, CloudFront", table_cell_body), Paragraph("~$1,100 / mo", table_cell_body), Paragraph("~55,000 EGP / mo", table_cell_body)],
        [Paragraph("Firebase FCM Push", table_cell_body), Paragraph("Android & iOS Push Notifications, Analytics", table_cell_body), Paragraph("FREE", table_cell_body), Paragraph("0 EGP", table_cell_body)],
        [Paragraph("Transactional Email", table_cell_body), Paragraph("SendGrid / AWS SES (500,000 emails/mo)", table_cell_body), Paragraph("~$60 / mo", table_cell_body), Paragraph("~3,000 EGP / mo", table_cell_body)],
        [Paragraph("SMS Gateway", table_cell_body), Paragraph("Twilio / Local Telecom (~20,000 SMS/mo)", table_cell_body), Paragraph("~$300 / mo", table_cell_body), Paragraph("~15,000 EGP / mo", table_cell_body)],
        [Paragraph("Payment Gateways", table_cell_body), Paragraph("Stripe / Fawry / PayMob / PayFort", table_cell_body), Paragraph("2.2% - 2.75% + $0.15", table_cell_body), Paragraph("Transactional Usage", table_cell_body)],
        [Paragraph("Developer Accounts", table_cell_body), Paragraph("Apple Developer ($99/yr) + Google Play ($25)", table_cell_body), Paragraph("~$10 / mo", table_cell_body), Paragraph("~500 EGP / mo", table_cell_body)],
        [Paragraph("TOTAL OPERATIONAL RUNNING COST", table_cell_header), Paragraph("Cloud & Third-Party APIs", table_cell_header), Paragraph("~$1,470 / mo", table_cell_header), Paragraph("~73,500 EGP / mo", table_cell_header)]
    ]
    t_op_pdf = Table(op_data, colWidths=[130, 190, 95, 115])
    t_op_pdf.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('BACKGROUND', (0,-1), (-1,-1), DARK_BG),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(t_op_pdf)

    doc.build(story)
    print(f"PDF created: {filename}")

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.abspath(__file__))
    docx_path = os.path.join(base_dir, "Limitless_Naturals_Technical_Proposal.docx")
    pdf_path = os.path.join(base_dir, "Limitless_Naturals_Technical_Proposal.pdf")
    
    create_docx(docx_path)
    create_pdf(pdf_path)
