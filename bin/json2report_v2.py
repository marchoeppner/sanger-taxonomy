#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
from reportlab.lib.enums import TA_JUSTIFY, TA_RIGHT
from reportlab.lib.units import cm
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.graphics.shapes import Drawing, Line
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, Preformatted, PageBreak
from reportlab.lib import colors

from datetime import date

today = date.today()
date = today.strftime("%d.%m.%Y")

# Command line arguments
parser = argparse.ArgumentParser(description="Script options")
parser.add_argument("--json")
parser.add_argument("--report")
parser.add_argument("--logo", required=True)
parser.add_argument("--output")
args = parser.parse_args()

# Use defaults or take from command line
outfile = args.output if args.output else "report.pdf"

content = []

pdf = SimpleDocTemplate(outfile, pagesize=A4,
                        rightMargin=72, leftMargin=72,
                        topMargin=35, bottomMargin=35)

# Define styles
styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))
styles.add(ParagraphStyle(name='H1', fontSize=14))
styles.add(ParagraphStyle(name='H2', fontSize=12))

styles.add(ParagraphStyle(name='H2_bg', fontSize=12))
styles.add(ParagraphStyle(name='Standard', fontSize=10))
styles.add(ParagraphStyle(name='H2_right', fontSize=12, alignment=TA_RIGHT))
styles.add(ParagraphStyle(name='Info', fontSize=8))
styles.add(ParagraphStyle(name='Sequence', fontSize=8, fontName="Courier"))

# The header
logo = Image(args.logo, height=1.4 * cm, width=8.5 * cm)
logo.hAlign = "RIGHT"
content.append(logo)
content.append(Spacer(1, 20))

##############################
# PDF construction starts here
##############################
disclaimer = f"Anlage zum Prüfbericht {args.report}"
content.append(Paragraph(disclaimer, styles["Normal"]))
content.append(Spacer(1, 12))

header = "Bericht zur Sanger-Sequenzierung"

content.append(Paragraph(header, styles["H1"]))
content.append(Spacer(1, 12))

subheader = "Taxonomische Bestimmung mittels Amplikon-Sequenzierung"
content.append(Paragraph(subheader, styles["H2"]))

content.append(Spacer(1, 12))

# Parse JSON file to extract relevant information
with open(args.json) as json_file:
    data = json.load(json_file)

sample = data["sample"]
run_date = data["run_date"]
alignment = data["tracy"]["alignment"]
seqs = data["tracy"]["seqs"]
composition = data["composition"][0]
consensus = data["consensus"]
this_consensus = next(item for item in consensus if item["name"] == composition["name"])
seq = data["fasta"]

settings = data["pipeline_settings"]

####################
# Section: Uebersicht
####################

content.append(Spacer(1, 4))

d = Drawing(100, 0.5)
d.add(Line(0, 0, 450, 0))
content.append(d)
content.append(Spacer(1, 20))

content.append(Paragraph("Übersicht", styles["H2_bg"]))
content.append(Spacer(1, 10))

summary = []

summary.append(["Untersuchte Probe", sample])
summary.append(["Ermitteltes Taxon", Paragraph(composition["name"], styles["Normal"])])
summary.append(["Taxon ID (NCBI)", Paragraph(composition["taxid"], styles["Normal"])])
summary.append(["Unterstuetzung", Paragraph(str(round(this_consensus["support"] * 100, 2)), styles["Normal"])])
summary.append(["Datum der Auswertung", run_date])

summary_table = Table(summary, colWidths=[7 * cm, 8 * cm], splitByRow=1, hAlign='LEFT')

summary_table.setStyle([
    ('VALIGN', (0, 0), (-1, -1), 'TOP')
])

content.append(summary_table)

content.append(Spacer(1, 20))

content.append(Paragraph("Konsensus-Sequenz", styles["H2_bg"]))
content.append(Spacer(1, 10))

for row in seq:
    content.append(Preformatted(row, styles["Sequence"]))

content.append(Spacer(1, 20))

content.append(Paragraph("Konsensus-Bildung", styles["H2_bg"]))
content.append(Spacer(1, 10))

for row in alignment:
    content.append(Preformatted(row, styles["Sequence"]))

content.append(PageBreak())

content.append(Paragraph("Einstellungen", styles["H2_bg"]))
content.append(Spacer(1, 10))

software = []
for key, values in settings.items():
    if type(values) is not dict:
        software.append([key, Paragraph(str(values), styles["Normal"])])

software_table = Table(software, colWidths=[7 * cm, 8 * cm], splitByRow=1, hAlign='LEFT')

software_table.setStyle([
    ('VALIGN', (0, 0), (-1, -1), 'TOP')
])

content.append(software_table)


pdf.build(content)
