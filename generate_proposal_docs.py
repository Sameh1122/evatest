import os
import sys
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import qn, nsdecls

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
    
    # Page setup - Margins
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)

    # Color Palette
    PRIMARY = RGBColor(16, 185, 129)     # Emerald Green #10B981
    SECONDARY = RGBColor(14, 165, 233)   # Cyan #06B6D4
    DARK_BG = RGBColor(15, 23, 42)       # Slate Dark #0F172A
    TEXT_DARK = RGBColor(30, 41, 59)     # Slate 800 #1E293B
    TEXT_MUTED = RGBColor(100, 116, 139) # Slate 500

    # Styles
    styles = doc.styles
    normal_style = styles['Normal']
    normal_style.font.name = 'Calibri'
    normal_style.font.size = Pt(11)
    normal_style.font.color.rgb = TEXT_DARK

    # Title Banner / Header
    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_brand = p_title.add_run("LIMITLESS NATURALS BY EVA PHARMA\n")
    run_brand.font.size = Pt(14)
    run_brand.font.bold = True
    run_brand.font.color.rgb = PRIMARY
    
    run_main = p_title.add_run("TECHNICAL & BUSINESS PROPOSAL\n")
    run_main.font.size = Pt(22)
    run_main.font.bold = True
    run_main.font.color.rgb = DARK_BG
    
    run_sub = p_title.add_run("Cross-Platform Mobile Application (iOS & Android) & Full-Stack Web Platform\nHigh-Availability Enterprise Solution for 2M Users & 2,000 Concurrent Connections")
    run_sub.font.size = Pt(12)
    run_sub.font.italic = True
    run_sub.font.color.rgb = TEXT_MUTED

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # Helper function for headings
    def add_custom_heading(text, level=1):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(6)
        run = p.add_run(text)
        run.font.bold = True
        if level == 1:
            run.font.size = Pt(16)
            run.font.color.rgb = PRIMARY
            # Add bottom border style or underline effect
        elif level == 2:
            run.font.size = Pt(13)
            run.font.color.rgb = DARK_BG
        else:
            run.font.size = Pt(11.5)
            run.font.color.rgb = SECONDARY
        return p

    # 1. Executive Summary
    add_custom_heading("1. Executive Summary", level=1)
    p = doc.add_paragraph(
        "This technical proposal outlines the end-to-end software architecture, infrastructure design, agile team structure, "
        "licensing breakdown, and execution roadmap for the Limitless Naturals Mobile Application (iOS & Android) and Web E-Commerce Platform. "
        "Engineered specifically for Eva Pharma, the platform seamlessly integrates personalized AI health recommendation engines, "
        "chronic disease safety contraindications, a multi-channel admin notification center, real-time logistics management, and "
        "scalable cloud infrastructure capable of serving 2,000,000+ registered clients with 2,000 peak concurrent active sessions."
    )
    p.paragraph_format.line_spacing = 1.15

    # 2. Infrastructure & System Specifications
    add_custom_heading("2. Proposed Infrastructure & Scale Specifications", level=1)
    doc.add_paragraph(
        "To guarantee 99.99% availability, zero sub-second latency, and horizontal elasticity, the system is designed using "
        "Containerized Microservices architecture deployed on AWS / Google Cloud with Managed Kubernetes (EKS/GKE)."
    )

    table_infra = doc.add_table(rows=1, cols=4)
    table_infra.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr_cells = table_infra.rows[0].cells
    headers = ["Metric / Layer", "Proposed Infrastructure Spec", "Scaling Policy", "Purpose / Rationale"]
    for i, title in enumerate(headers):
        hdr_cells[i].text = title
        set_cell_background(hdr_cells[i], "0F172A")
        hdr_cells[i].paragraphs[0].runs[0].font.bold = True
        hdr_cells[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    infra_data = [
        ("Target Load", "2,000,000 Registered Clients | 2,000 Concurrent Users", "N/A", "Design benchmark for 150 requests/sec throughput"),
        ("DNS & CDN Layer", "Cloudflare Enterprise / AWS CloudFront + Route53", "Edge Caching & DDoS Mitigation", "Static asset acceleration, Web Application Firewall (WAF), SSL"),
        ("Load Balancer", "AWS Application Load Balancer (ALB) Multi-AZ", "Auto-SSL & Health Checks", "Distributes API traffic across healthy node instances"),
        ("App Server Cluster", "AWS EKS (Kubernetes) - 3x c6g.xlarge (4 vCPU, 8GB RAM)", "HPA: Auto-scales to 10 nodes at 70% CPU", "Runs Node.js API instances & Flutter Web static assets"),
        ("Cache & Session", "Redis Cluster (AWS ElastiCache, 2x cache.m6g.large)", "Multi-AZ Failover + In-Memory Replication", "Sub-5ms session storage, shopping carts, rate-limiting"),
        ("Primary Database", "AWS Aurora PostgreSQL Multi-AZ (Primary 4 vCPU, 32GB RAM)", "1 Read Replica for Reports & Analytics", "ACID-compliant relational store for orders, users, catalog"),
        ("Object Storage", "AWS S3 Bucket with CDN distribution", "Lifecycle Archival to Glacier", "Product images, user health profile documents, avatars")
    ]

    for row_data in infra_data:
        row_cells = table_infra.add_row().cells
        for i, val in enumerate(row_data):
            row_cells[i].text = val
            set_cell_background(row_cells[i], "F8FAFC" if i % 2 == 0 else "FFFFFF")

    # 3. Agile Scrum Team Structure
    add_custom_heading("3. Agile Scrum Team Structure & Methodology", level=1)
    doc.add_paragraph(
        "The project will be executed using the Scrum Agile Framework operating in 2-week Sprint cycles. "
        "The dedicated team consists of 11 seasoned engineering specialists:"
    )

    team_members = [
        ("1x Product Owner (PO)", "Defines business backlog, accepts user stories, aligns feature prioritization with Eva Pharma stakeholders."),
        ("1x Scrum Master (SM)", "Facilitates daily standups, sprint planning, backlog grooming, retrospectives, and removes blockers."),
        ("1x UI/UX Designer", "Crafts Figma design system, pixel-perfect iOS/Android interfaces, web design, and interactive prototypes."),
        ("2x Mobile Developers", "Builds cross-platform native iOS & Android apps using Flutter, managing state, push notifications, and local offline cache."),
        ("3x Backend Developers", "Develops Node.js RESTful APIs, AI recommendation engine logic, payment gateways, notifications, and DB schemas."),
        ("1x DevOps Engineer", "Configures CI/CD pipelines (GitHub Actions), Infrastructure-as-Code (Terraform), Kubernetes, and Grafana monitoring."),
        ("2x QC / QA Engineers", "Executes manual functional tests, automated API testing (Postman/Jest), security scanning, and device matrices.")
    ]

    for role, desc in team_members:
        p = doc.add_paragraph(style='List Bullet')
        r_role = p.add_run(f"{role}: ")
        r_role.font.bold = True
        p.add_run(desc)

    # 4. Project Master Timeline
    add_custom_heading("4. Master Project Development Timeline (8 Months)", level=1)
    doc.add_paragraph(
        "The total engagement spans 8 calendar months organized into 5 structured project phases:"
    )

    timeline_data = [
        ("Phase 1: Requirement Gathering & Blueprinting", "1 Month", "Month 1", "SRS document, Figma UX/UI prototypes, architecture design, API contracts"),
        ("Phase 2: Agile Core Development", "3 Months", "Months 2–4", "6 Sprints x 2 weeks: Client portal, AI engine, Admin Notification Center, Distributor app"),
        ("Phase 3: System Integration Testing (SIT)", "1 Month", "Month 5", "Full API integration testing, security penetration testing, 2K load testing"),
        ("Phase 4: User Acceptance Testing (UAT)", "2 Months", "Months 6–7", "Staging environment deployment, client UAT sign-off, feedback iterations"),
        ("Phase 5: Go-Live & Hypercare Support", "1 Month", "Month 8", "Production deployment, App Store & Google Play launch, 30-day hypercare support")
    ]

    table_timeline = doc.add_table(rows=1, cols=4)
    table_timeline.alignment = WD_TABLE_ALIGNMENT.CENTER
    t_hdr = table_timeline.rows[0].cells
    for i, title in enumerate(["Project Phase", "Duration", "Schedule", "Key Deliverables"]):
        t_hdr[i].text = title
        set_cell_background(t_hdr[i], "0F172A")
        t_hdr[i].paragraphs[0].runs[0].font.bold = True
        t_hdr[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    for row_data in timeline_data:
        r_cells = table_timeline.add_row().cells
        for i, val in enumerate(row_data):
            r_cells[i].text = val

    # 5. Licenses & Operational Costs
    add_custom_heading("5. Licenses, Third-Party Integrations & Operational Cost Estimation", level=1)
    doc.add_paragraph(
        "Below is an itemized breakdown of third-party software licenses, cloud hosting fees, and operational service estimates required to run the platform:"
    )

    cost_data = [
        ("Cloud Infrastructure (AWS / GCP)", "AWS ALB, EKS, Aurora Postgres, ElastiCache, S3, CloudFront", "~$850 - $1,400 / month", "Based on 2M registered users & 2,000 peak concurrent active load"),
        ("Firebase Cloud Messaging (FCM)", "Android & iOS Push Notifications, Crashlytics, Analytics", "FREE (Unlimited)", "Google Firebase standard tier for mobile push alerts"),
        ("Payment Gateways", "Stripe / Fawry / PayMob / PayFort integrations", "2.2% - 2.75% + $0.15 per transaction", "Pay-as-you-go transaction fee structure"),
        ("Transactional Email Service", "SendGrid / AWS SES (500,000 emails/month)", "~$40 - $80 / month", "Order receipts, password reset, automated health campaigns"),
        ("SMS Notification Gateway", "Twilio / Local Telecom Aggregator (~20,000 SMS/mo)", "~$200 - $400 / month", "OTP verification, abandoned cart SMS alerts"),
        ("Developer Licenses", "Apple Developer Enterprise ($99/yr) + Google Play ($25 one-time)", "~$124 total (Annual)", "Official App Store and Google Play distribution accounts")
    ]

    table_costs = doc.add_table(rows=1, cols=4)
    table_costs.alignment = WD_TABLE_ALIGNMENT.CENTER
    c_hdr = table_costs.rows[0].cells
    for i, title in enumerate(["Service / Integration", "Scope & Tooling", "Estimated Cost Structure", "Operational Notes"]):
        c_hdr[i].text = title
        set_cell_background(c_hdr[i], "0F172A")
        c_hdr[i].paragraphs[0].runs[0].font.bold = True
        c_hdr[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    for row_data in cost_data:
        r_cells = table_costs.add_row().cells
        for i, val in enumerate(row_data):
            r_cells[i].text = val

    # 6. Feature Matrix & Business Architecture
    add_custom_heading("6. Application Features & Business Architecture", level=1)
    doc.add_paragraph(
        "The solution is built on a modular role-based architecture serving four primary user archetypes:"
    )

    features = [
        ("1. Mobile & Web Client Portal", "Personalized AI supplement recommender based on age/gender/goals, chronic disease safety contraindication checker (Hypertension, Kidney Disease, Allergies), daily hydration calculator, shopping cart, promo code redemption, credit card/COD checkout, and real-time order tracking stepper."),
        ("2. Admin Notification Center & Portal", "Multi-channel notification engine (Android Push, iOS Push, Email, SMS), target segment rules (chronic patients, low stock alerts, abandoned cart), automated AI recommendation broadcasts, promo discount manager, product catalog CRUD, and revenue/sales analytics dashboard."),
        ("3. Distributor Logistics Portal", "Delivery driver queue management, status progression stepper (Pending -> Picked Up -> Out for Delivery -> Delivered), warehouse stock capacity gauges, and low stock reorder triggers."),
        ("4. Visitor / Public Storefront", "Seamless browsing of official Limitless Naturals catalog, health category filters (Daily Wellness, Immune Defense, Hydration), ingredient breakdown, and quick login/registration prompt.")
    ]

    for title, detail in features:
        add_custom_heading(title, level=2)
        doc.add_paragraph(detail)

    # 7. Milestone Payment Schedule
    add_custom_heading("7. Milestone-Based Payment Schedule", level=1)
    doc.add_paragraph(
        "Payments are structured across project milestones linked directly to verified deliverables and sign-offs:"
    )

    milestone_data = [
        ("Milestone 1: Project Kickoff & SRS Approval", "Phase 1 (Month 1)", "15%", "Approval of SRS document, Figma designs, and setup of cloud staging environments"),
        ("Milestone 2: Core Development Sprint Phase A", "Phase 2 (Months 2–3)", "25%", "Completion of Sprints 1–3: Client App, Authentication, AI Engine & Product Catalog"),
        ("Milestone 3: Core Development Sprint Phase B", "Phase 2 (Month 4)", "25%", "Completion of Sprints 4–6: Admin Notification Center, Checkout, Distributor App"),
        ("Milestone 4: System Integration Testing (SIT)", "Phase 3 (Month 5)", "15%", "Successful completion of SIT, security audit, and 2,000 concurrent load test"),
        ("Milestone 5: User Acceptance Testing (UAT)", "Phase 4 (Months 6–7)", "10%", "Client UAT sign-off and completion of all user feedback adjustments"),
        ("Milestone 6: Go-Live & Handover", "Phase 5 (Month 8)", "10%", "Successful deployment to App Store, Google Play, Web hosting, and hypercare handover")
    ]

    table_m = doc.add_table(rows=1, cols=4)
    table_m.alignment = WD_TABLE_ALIGNMENT.CENTER
    m_hdr = table_m.rows[0].cells
    for i, title in enumerate(["Milestone", "Target Timeline", "Payment %", "Trigger Condition / Deliverable"]):
        m_hdr[i].text = title
        set_cell_background(m_hdr[i], "0F172A")
        m_hdr[i].paragraphs[0].runs[0].font.bold = True
        m_hdr[i].paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

    for row_data in milestone_data:
        r_cells = table_m.add_row().cells
        for i, val in enumerate(row_data):
            r_cells[i].text = val

    doc.save(filename)
    print(f"DOCX created: {filename}")

def create_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40
    )

    styles = getSampleStyleSheet()
    
    PRIMARY = colors.HexColor("#10B981")
    DARK_BG = colors.HexColor("#0F172A")
    TEXT_DARK = colors.HexColor("#1E293B")

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=DARK_BG,
        alignment=1,
        spaceAfter=15
    )

    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#64748B"),
        alignment=1,
        spaceAfter=20
    )

    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=14,
        leading=18,
        textColor=PRIMARY,
        spaceBefore=14,
        spaceAfter=8
    )

    h2_style = ParagraphStyle(
        'H2',
        parent=styles['Heading3'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=15,
        textColor=DARK_BG,
        spaceBefore=10,
        spaceAfter=4
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['BodyText'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=TEXT_DARK,
        spaceAfter=8
    )

    table_cell_header = ParagraphStyle(
        'TH',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11,
        textColor=colors.white
    )

    table_cell_body = ParagraphStyle(
        'TD',
        fontName='Helvetica',
        fontSize=8,
        leading=10.5,
        textColor=TEXT_DARK
    )

    story = []

    # Title Banner
    story.append(Paragraph("LIMITLESS NATURALS BY EVA PHARMA", ParagraphStyle('BBrand', fontName='Helvetica-Bold', fontSize=12, leading=14, textColor=PRIMARY, alignment=1)))
    story.append(Paragraph("TECHNICAL & BUSINESS PROPOSAL", title_style))
    story.append(Paragraph("Cross-Platform Mobile Application (iOS & Android) & Full-Stack Web Platform<br/>High-Availability Enterprise Solution for 2M Clients & 2,000 Concurrent Connections", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=PRIMARY, spaceBefore=5, spaceAfter=15))

    # 1. Executive Summary
    story.append(Paragraph("1. Executive Summary", h1_style))
    story.append(Paragraph(
        "This technical proposal outlines the software architecture, infrastructure design, agile team structure, "
        "licensing breakdown, and execution roadmap for the Limitless Naturals Mobile Application (iOS & Android) and Web Platform. "
        "Engineered for Eva Pharma, the solution integrates personalized AI health recommendations, chronic disease safety contraindications, "
        "a multi-channel admin notification center, real-time logistics management, and scalable cloud infrastructure for 2,000,000+ registered clients with 2,000 peak concurrent active sessions.",
        body_style
    ))

    # 2. Infrastructure
    story.append(Paragraph("2. Proposed Infrastructure & Scale Specifications", h1_style))
    story.append(Paragraph("Target Load: 2,000,000 Registered Clients | 2,000 Peak Active Concurrent Sessions", body_style))

    infra_table_data = [
        [Paragraph("Metric / Layer", table_cell_header), Paragraph("Proposed Infra Spec", table_cell_header), Paragraph("Scaling Policy", table_cell_header), Paragraph("Purpose / Rationale", table_cell_header)],
        [Paragraph("DNS & CDN", table_cell_body), Paragraph("Cloudflare Enterprise / AWS CloudFront", table_cell_body), Paragraph("Edge Caching & WAF", table_cell_body), Paragraph("DDoS protection & static acceleration", table_cell_body)],
        [Paragraph("Load Balancer", table_cell_body), Paragraph("AWS ALB Multi-AZ", table_cell_body), Paragraph("Auto-SSL & Health Check", table_cell_body), Paragraph("API traffic distribution", table_cell_body)],
        [Paragraph("App Servers", table_cell_body), Paragraph("AWS EKS 3x c6g.xlarge (4 vCPU, 8GB)", table_cell_body), Paragraph("HPA: Auto-scale to 10 nodes", table_cell_body), Paragraph("Node.js API & static web serving", table_cell_body)],
        [Paragraph("Redis Cache", table_cell_body), Paragraph("AWS ElastiCache 2x cache.m6g.large", table_cell_body), Paragraph("Multi-AZ In-Memory Replication", table_cell_body), Paragraph("Sub-5ms cart & session storage", table_cell_body)],
        [Paragraph("Primary DB", table_cell_body), Paragraph("AWS Aurora PostgreSQL (Primary + 1 Replica)", table_cell_body), Paragraph("Auto-scaling Read Replica", table_cell_body), Paragraph("ACID database for users & orders", table_cell_body)]
    ]

    t_infra = Table(infra_table_data, colWidths=[80, 150, 130, 170])
    t_infra.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_infra)
    story.append(Spacer(1, 10))

    # 3. Scrum Team
    story.append(Paragraph("3. Agile Scrum Team Structure (11 Specialists)", h1_style))
    scrum_text = (
        "<b>• 1x Product Owner (PO):</b> Defines business backlog & aligns feature prioritization with Eva Pharma.<br/>"
        "<b>• 1x Scrum Master (SM):</b> Facilitates 2-week Sprint ceremonies, daily standups, and removes impediments.<br/>"
        "<b>• 1x UI/UX Designer:</b> Crafts Figma design system, iOS/Android native mobile interfaces, and web layouts.<br/>"
        "<b>• 2x Mobile Developers:</b> Builds cross-platform Flutter iOS & Android apps with offline caching.<br/>"
        "<b>• 3x Backend Developers:</b> Node.js RESTful APIs, AI recommendation engine, payment & notification services.<br/>"
        "<b>• 1x DevOps Engineer:</b> CI/CD pipelines (GitHub Actions), Terraform IaC, Kubernetes, Grafana monitoring.<br/>"
        "<b>• 2x QC / QA Engineers:</b> Manual & automated API testing, security scanning, mobile device testing matrix."
    )
    story.append(Paragraph(scrum_text, body_style))
    story.append(Spacer(1, 10))

    # 4. Timeline
    story.append(Paragraph("4. Master Project Timeline (8 Months)", h1_style))
    timeline_table_data = [
        [Paragraph("Project Phase", table_cell_header), Paragraph("Duration", table_cell_header), Paragraph("Schedule", table_cell_header), Paragraph("Key Deliverables", table_cell_header)],
        [Paragraph("Phase 1: Requirements", table_cell_body), Paragraph("1 Month", table_cell_body), Paragraph("Month 1", table_cell_body), Paragraph("SRS, Figma designs, API contracts", table_cell_body)],
        [Paragraph("Phase 2: Agile Core Dev", table_cell_body), Paragraph("3 Months", table_cell_body), Paragraph("Months 2–4", table_cell_body), Paragraph("6 Sprints x 2 wks: Client, Admin & Distributor", table_cell_body)],
        [Paragraph("Phase 3: SIT Testing", table_cell_body), Paragraph("1 Month", table_cell_body), Paragraph("Month 5", table_cell_body), Paragraph("API integration, security & 2K load test", table_cell_body)],
        [Paragraph("Phase 4: UAT Testing", table_cell_body), Paragraph("2 Months", table_cell_body), Paragraph("Months 6–7", table_cell_body), Paragraph("Client UAT sign-off & feedback iterations", table_cell_body)],
        [Paragraph("Phase 5: Go-Live & Support", table_cell_body), Paragraph("1 Month", table_cell_body), Paragraph("Month 8", table_cell_body), Paragraph("App Store / Play Store launch & hypercare", table_cell_body)]
    ]
    t_timeline = Table(timeline_table_data, colWidths=[120, 70, 70, 270])
    t_timeline.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_timeline)
    story.append(Spacer(1, 10))

    # 5. Licenses & Operational Costs
    story.append(Paragraph("5. Operational Cost Estimation & Third-Party Services", h1_style))
    cost_table_data = [
        [Paragraph("Service / Integration", table_cell_header), Paragraph("Scope & Tooling", table_cell_header), Paragraph("Estimated Cost", table_cell_header)],
        [Paragraph("Cloud Hosting (AWS)", table_cell_body), Paragraph("ALB, EKS, Aurora Postgres, ElastiCache, S3, CloudFront", table_cell_body), Paragraph("~$850 - $1,400 / mo", table_cell_body)],
        [Paragraph("Firebase (FCM)", table_cell_body), Paragraph("Push Notifications (iOS & Android), Analytics", table_cell_body), Paragraph("FREE (Unlimited)", table_cell_body)],
        [Paragraph("Payment Gateways", table_cell_body), Paragraph("Stripe / Fawry / PayMob / PayFort", table_cell_body), Paragraph("2.2% - 2.75% + $0.15/tx", table_cell_body)],
        [Paragraph("Transactional Email", table_cell_body), Paragraph("SendGrid / AWS SES (500,000 emails/mo)", table_cell_body), Paragraph("~$40 - $80 / mo", table_cell_body)],
        [Paragraph("SMS Gateway", table_cell_body), Paragraph("Twilio / Local Telecom (~20,000 SMS/mo)", table_cell_body), Paragraph("~$200 - $400 / mo", table_cell_body)],
        [Paragraph("Developer Accounts", table_cell_body), Paragraph("Apple Developer ($99/yr) + Google Play ($25 one-time)", table_cell_body), Paragraph("~$124 total", table_cell_body)]
    ]
    t_cost = Table(cost_table_data, colWidths=[130, 240, 160])
    t_cost.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_cost)
    story.append(Spacer(1, 10))

    # 6. Milestone Payments
    story.append(Paragraph("6. Milestone-Based Payment Structure", h1_style))
    m_table_data = [
        [Paragraph("Milestone", table_cell_header), Paragraph("Schedule", table_cell_header), Paragraph("%", table_cell_header), Paragraph("Trigger Condition / Deliverable", table_cell_header)],
        [Paragraph("M1: Requirements", table_cell_body), Paragraph("Month 1", table_cell_body), Paragraph("15%", table_cell_body), Paragraph("SRS & Figma designs approval", table_cell_body)],
        [Paragraph("M2: Core Dev Phase A", table_cell_body), Paragraph("Months 2–3", table_cell_body), Paragraph("25%", table_cell_body), Paragraph("Sprints 1–3: Client App, Auth & AI Engine", table_cell_body)],
        [Paragraph("M3: Core Dev Phase B", table_cell_body), Paragraph("Month 4", table_cell_body), Paragraph("25%", table_cell_body), Paragraph("Sprints 4–6: Admin Notifications & Distributor App", table_cell_body)],
        [Paragraph("M4: SIT Testing", table_cell_body), Paragraph("Month 5", table_cell_body), Paragraph("15%", table_cell_body), Paragraph("SIT & 2,000 concurrent load test sign-off", table_cell_body)],
        [Paragraph("M5: UAT Testing", table_cell_body), Paragraph("Months 6–7", table_cell_body), Paragraph("10%", table_cell_body), Paragraph("Client UAT sign-off & final tweaks", table_cell_body)],
        [Paragraph("M6: Go-Live & Support", table_cell_body), Paragraph("Month 8", table_cell_body), Paragraph("10%", table_cell_body), Paragraph("App Store / Play Store deployment & handover", table_cell_body)]
    ]
    t_m = Table(m_table_data, colWidths=[110, 70, 40, 310])
    t_m.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK_BG),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_m)

    doc.build(story)
    print(f"PDF created: {filename}")

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.abspath(__file__))
    docx_path = os.path.join(base_dir, "Limitless_Naturals_Technical_Proposal.docx")
    pdf_path = os.path.join(base_dir, "Limitless_Naturals_Technical_Proposal.pdf")
    
    create_docx(docx_path)
    create_pdf(pdf_path)
