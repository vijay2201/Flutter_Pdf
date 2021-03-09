import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:open_file/open_file.dart' as open_file;
import 'package:flutter/services.dart';

/// Represents the PDF stateful widget class.
class CreatePdfStatefulWidget extends StatefulWidget {
  /// Initalize the instance of the [CreatePdfStatefulWidget] class.
  const CreatePdfStatefulWidget({Key key, this.title}) : super(key: key);

  /// title.
  final String title;
  @override
  _CreatePdfState createState() => _CreatePdfState();
}

class _CreatePdfState extends State<CreatePdfStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: const Text(
                'Generate PDF',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: _generatePDF,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _generatePDF() async {
    //Create a new PDF document
    final PdfDocument document = PdfDocument();
    document.pages.add().graphics.drawImage(
        PdfBitmap(await _readImageData('first.png')),
        const Rect.fromLTWH(50, 50, 425, 642));

    final PdfSection section = document.sections.add();
    final PdfPage titlePage = document.pages.add();

    _addParagraph(
        titlePage,
        'To\n-----\n-------------\n\nSubject : Price details for XX kW On-Grid Rooftop Solar Power plant & BOS under the subsidy program of PGVCL.',
        Rect.fromLTWH(20, 60, 495, titlePage.getClientSize().height),
        false,
        mainTitle: false);

    _addParagraph(
        titlePage,
        'Dear Sir,\nWith reference to our discussion, we are herewith submitting the price details along with the subsidy breakup for your kind consideration and final confirmation of the order. We hope it is in line with your requirement.',
        Rect.fromLTWH(20, 170, 495, titlePage.getClientSize().height),
        false,
        mainTitle: false);

    final DateFormat format = DateFormat.yMMMMd('en_US');
    final String myDate = '\tDate: ' + format.format(DateTime.now());

    //Create a header template and draw a text.
    final PdfPageTemplateElement headerElement =
        PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50), titlePage);
    headerElement.graphics.setTransparency(1);
    headerElement.graphics.drawString(
        'ASPL Ref. No.: ASPL/QUO/20-21/CO\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t$myDate',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: const Rect.fromLTWH(0, 0, 515, 50),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle));
    headerElement.graphics
        .drawLine(PdfPens.black, const Offset(0, 49), const Offset(515, 49));
    section.template.top = headerElement;
    //Create a footer template and draw a text.
    final PdfPageTemplateElement footerElement =
        PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50), titlePage);
    footerElement.graphics.setTransparency(0.6);
    PdfCompositeField(text: 'Page {0} of {1}', fields: <PdfAutomaticField>[
      PdfPageNumberField(brush: PdfBrushes.black),
      PdfPageCountField(brush: PdfBrushes.black)
    ]).draw(footerElement.graphics, const Offset(450, 35));
    section.template.bottom = footerElement;
    //Add a new PDF page

    final Size pageSize = titlePage.getClientSize();

    final PdfGrid grid1 = _getGrid1();
    //Draw the header section by creating text element
    final PdfLayoutResult result = _drawHeader(titlePage, pageSize, grid1);
    //Draw grid
    _drawGrid(titlePage, grid1, result);


    PdfGrid grid = PdfGrid();
//Add the columns to the grid
    grid.columns.add(count: 2);

//Add header to the grid
    grid.headers.add(1);

//Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = '\t\t\t\t\tTax';
    header.cells[1].value = '\t\t\t\t\tAmount(INR)';


//Add rows to grid
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'Subsidy 40% (-)';
    row.cells[1].value = 'XXXXX/-';


    row = grid.rows.add();
    row.cells[0].value = 'Subsidy 20% (-)';
    row.cells[1].value = 'XXXXX/-';


    row = grid.rows.add();
    row.cells[0].value = 'System Price (to be paid by user)';
    row.cells[1].value = 'XXXXX/-';


    row = grid.rows.add();
    row.cells[0].value = 'System Strengthening Charges (MMS) (+)';
    row.cells[1].value = 'XXXXX/-';

    row = grid.rows.add();
    row.cells[0].value = 'GST-18% (+)';
    row.cells[1].value = 'XXXXX/-';

    row = grid.rows.add();
    row.cells[0].value = '\t\t\t\t\t\t\t\t\tGrand TOTAL';
    row.cells[1].value = 'XXXXX/-';


//Set the grid style
    grid.style = PdfGridStyle(

        cellPadding: PdfPaddings(left: 5, right: 5, top: 2, bottom: 2),
        backgroundBrush: PdfBrushes.white,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 15));

//Draw the grid
    grid.draw(page: titlePage, bounds: const Rect.fromLTWH(20, 460, 0, 0));

    final PdfPage page2 = document.pages.add();

    page2.graphics.drawString('TERMS & CONDITIONS:',
        PdfStandardFont(PdfFontFamily.timesRoman, 25),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 10, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page2.graphics
        .drawLine(PdfPens.black, const Offset(120, 37), const Offset(400, 37));


    page2.graphics.drawString(
        '(For Solar Roof Top System under GOVT (PGVCL) subsidy project for the Year 2020-21)',
        PdfStandardFont(PdfFontFamily.timesRoman, 13),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 50, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    page2.graphics.drawString('Document:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 85, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page2.graphics.drawString('\n=> Application Form \n=> Passport size photo- 2 nos\n=> Latest Electricity Bill - 1 copy\n=> Aadhar Card - 1 copy\n=> Property Tax Bill - 1 copy\n=> PAN Card - 1 copy\n=> Cast Certificate',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 95, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page2.graphics.drawString('Note:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 240, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page2.graphics.drawString('\n=> Name in Electricity Bill will be considered as Applicant automatically\n=> All documents with Applicant Signature\n=> Signature MUST be same as in DISCOM\n=> Load extension, if suggested by DISCOM, will be in Customer scope only.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 250, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page2.graphics.drawString('System Capacity, Design & Client Approval:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 350, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page2.graphics.drawString('\n=> Above price includes roof top system material, installation, taxes.\n=> As per tender norms solar connectivity charge of discome meter, franking charge and Application charge are in customer scope.\n=> System rate declared by GOVT is for the system of capacity 1kw, 2kw, and 3kw and so on whereas the actual system capacity is defined from the numbers of solar panels installed on site.\n=> System price and subsidy will be calculated on the ACTUAL system supplied to Customers.\n =>	Combination of Solar Modules and Inverters will be the sole right of Company as per the terms and conditions of the GOVT regulations.\n=> Site survey will be conducted by technical team of company.\n=> Proposed site layout will be submitted to Customer for his understanding of the site feasibility and panel mounting conditions.\n=> Customer has to APPROVE the site layout and on site work will be executed as the approved design only.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 360, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    final PdfPage page3 = document.pages.add();

    page3.graphics.drawString(
        'Solar Connectivity Charges:', PdfStandardFont(PdfFontFamily.timesRoman, 25),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 10, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page3.graphics
        .drawLine(PdfPens.black, const Offset(110, 35), const Offset(400, 35));

    PdfGrid grid12 = PdfGrid();
//Add the columns to the grid
    grid12.columns.add(count: 6);

//Add header to the grid
    grid12.headers.add(1);

//Add the rows to the grid
    PdfGridRow header1 = grid12.headers[0];
    header1.cells[0].value = 'Sr. No.';
    header1.cells[1].value = 'Discome';
    header1.cells[2].value = '1 phase';
    header1.cells[3].value = 'Amount approx';
    header1.cells[4].value = '3 Phase ';
    header1.cells[5].value = 'AmountApprox';

//Add rows to grid
    PdfGridRow row1 = grid12.rows.add();
    row1.cells[0].value = '1';
    row1.cells[1].value = 'TPL';
    row1.cells[2].value = '1 to 4 kw\n\n\n4 to 6 kw';
    row1.cells[3].value = '4,270/- to 5000/-\n\n5000/- to 7500/-';
    row1.cells[4].value = '6 kw or above';
    row1.cells[5].value = '15,000/- or above';


    row1 = grid12.rows.add();
    row1.cells[0].value = '2';
    row1.cells[1].value = 'UGVCL';
    row1.cells[2].value = '1 to 6 kw';
    row1.cells[3].value = '2,950/- to 4,000';
    row1.cells[4].value = '6 kw or above';
    row1.cells[5].value = '13,410/- to above';

    row1 = grid12.rows.add();
    row1.cells[0].value = '3';
    row1.cells[1].value = 'PGVCL';
    row1.cells[2].value = '1 to 6 kw';
    row1.cells[3].value = '2,950/- to 4,000';
    row1.cells[4].value = '6 kw or above';
    row1.cells[5].value = '13,410/- to above';

    row1 = grid12.rows.add();
    row1.cells[0].value = '4';
    row1.cells[1].value = 'MGVCL';
    row1.cells[2].value = '1 to 6 kw';
    row1.cells[3].value = '2,950/- to 4,000';
    row1.cells[4].value = '6 kw or above';
    row1.cells[5].value = '13,410/- to above';

    row1 = grid12.rows.add();
    row1.cells[0].value = '5';
    row1.cells[1].value = 'DGVCL';
    row1.cells[2].value = '1 to 6 kw';
    row1.cells[3].value = '2,950/- to 4,000';
    row1.cells[4].value = '6 kw or above';
    row1.cells[5].value = '13,410/- to above';

    grid12.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 3, right: 3, top: 5, bottom: 5),
        backgroundBrush: PdfBrushes.white,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 15));

    grid12.draw(page: page3, bounds: const Rect.fromLTWH(0, 50, 0, 0));

    page3.graphics.drawString(
        '\t\n=> Any deviations, introduced after customer APPROVAL, will be charges extra and considered only if the feasibility is defined',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 380, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page3.graphics.drawString('Additional Structure & Cable:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 435, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page3.graphics.drawString('\n=> Above rate includes system supply, installation with standard structure of 300 mm ground clearance and 5 years’ warranty.\n=> If the structure is customized, then the difference of the customized structure will be charged extra.\n=> Cable length up to 30 meter is included in above rates. Above 30 meter, cable will be charged extra.\n=> Inverter DONGLE is given either Wi-Fi or GPRS as per tender norms.\n=> All the material supplied under Govt. Subsidy scheme will be as per the Govt. standards.\n=> The Customized Structure charges and cable above 30-meter length are also as per the GOVT Norms.\n=> Isolation Switch Charges Extra.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 445, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));


    final PdfPage page4 = document.pages.add();

    PdfGrid grid0 = PdfGrid();
//Add the columns to the grid
    grid0.columns.add(count: 2);

//Add header to the grid
    grid0.headers.add(1);

//Add the rows to the grid
    PdfGridRow header0 = grid0.headers[0];
    header0.cells[0].value = '\t\t\t\t\tPhase';
    header0.cells[1].value = '\t\t\t\t\tAmount(INR)';


//Add rows to grid
    PdfGridRow row0 = grid0.rows.add();
    row0.cells[0].value = '1 Phase';
    row0.cells[1].value = '700/-';

    row0 = grid0.rows.add();
    row0.cells[0].value = '3 Phase';
    row0.cells[1].value = '1100/-';


//Set the grid style
    grid0.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 5, right: 5, top: 2, bottom: 2),
        backgroundBrush: PdfBrushes.white,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 15));

//Draw the grid
    grid0.draw(page: page4, bounds: const Rect.fromLTWH(0, 10, 0, 0));

    page4.graphics.drawString('Payment:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 110, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page4.graphics.drawString('\n=> Customer is requested to make Payment as per Govt Norms.\n=> By Cheque in favour of “AMPLE SOLAR PVT LTD”\n=> By NEFT/RTGS in Bank of Baroda (GEZIA Branch) Current A/c of “AMPLE SOLAR PVT LTD”\n A/c no: 30390 200 000 339 (IFSC: BARB0GEZIAX) “fifth character is zero”',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 120, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page4.graphics.drawString('Cancellation of order and REFUND of Payment:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 230, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page4.graphics.drawString('\n=> Order cancellation from Customer side due to any personal reason will NOT be entertained by Company because one the application is registered with GOVT; company is answerable for the NON-Execution of the booked capacity.\n=> If the Order will be cancelled before the application is submitted to the GOVT, 20% amount will be deducted as the processing charges from Company.\n=> In feature if any changes in terms the company have rights to cancel the application any time.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 240, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page4.graphics.drawString('Execution Time:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 390, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page4.graphics.drawString('\n=> The time frame from the Application to the Commissioning of the project includes many intermediate process.\n=> Approximate 65 to 75 days from the date of feasibility approved and Payment received.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 400, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));


    page4.graphics.drawString('User Scope of Work and Responsibilities:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 490, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page4.graphics.drawString('\n=> To clean the solar modules with clean water at least once in a week time.\n=> Cleaning can be done with mop, cotton clothes or even with high pressure jet water sprinkler.\n=> Any material which may create the scratches on the glass surface are to be avoided for the cleaning.\n=> Once the system is commissioned, it is the own responsibility of user to ensure the safety of the system from physical damage through any of the mode.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 500, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    final PdfPage page5 = document.pages.add();

    page5.graphics.drawString('System Errors and Rectifications:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 10, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page5.graphics.drawString('\n=> System monitoring facility is provided along with each of the inverter with LOCAL and REMOTE monitoring option.\n=> User have to keep an eye for the daily performance of the system.\n=> Any generation losses accrued and drawn into the attention to Company after a long time will be borne by user only.\n=> If at any short of time, user is not getting the standard system generation then it is always advisable that the user must check the cleaning system of the system\n=> During and fault occurrence in the system, primary data like Photos of the inverter display, panels photos, meter photos to be shared to our technical team. So that they can rectify the error in the least possible time.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 20, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));


    page5.graphics.drawString('Amendments/Modifications in GOVT Policy/Norms:',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 215, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page5.graphics.drawString('\n=> Any changes/Modification defined by the Govt. Authorities will be bound and applicable to user and company as per the rules.',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(10, 225, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));


    page5.graphics
        .drawLine(PdfPens.black, const Offset(0, 400), const Offset(700, 400));

    page5.graphics.drawString('(Authorized sign)',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 410, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    page5.graphics.drawString('(Applicant’s Signature)',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 410, titlePage.getClientSize().width,
            titlePage.getClientSize().height),
        format: PdfStringFormat(alignment: PdfTextAlignment.right));

    final List<int> bytes = document.save();
    //Dispose the document.
    document.dispose();
    //Get the storage folder location using path_provider package.
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/output.pdf');
    await file.writeAsBytes(bytes);
    //Launch the file (used open_file package)
    await open_file.OpenFile.open('$path/output.pdf');
  }

  PdfLayoutResult _drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {}

  //Draws the grid
  void _drawGrid(page8, PdfGrid grid, PdfLayoutResult result) {
    result = grid.draw(page: page8, bounds: Rect.fromLTWH(20, 250, 0, 0));
  }

  PdfGrid _getGrid1() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Sr.No';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Particulars';
    headerRow.cells[2].value = 'Quantity (In No\’s)';
    headerRow.cells[3].value = 'Price (Per kw)';
    headerRow.cells[4].value = 'Total Amount (INR)';

    _addProducts(
        '1',
        'Solar power plant of XX kW along with BOS as below:\n\n\n-SPV Modules of 330 watt: X No’s\nMake- APS/SOLARIUM/SANELITE/JAKSON & EQUIVALENT\n-Inverter: XX kw X phase\nMake- SAJ/APS/INVT/FOX & EQUIVALENT\n-Module mounting structure (HDGI 80 micron)\n-DC & AC Cables\nMake- Jainflex/Polycab\n-Earthing KIT as per PGVCL norms.\n-DC & AC Protection enclosures\nMake- Ample Solar\n-Hardware and accessories for system',
        '1',
        'XXXXX/-',
        'XXXXX/-',
        grid);


    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void _addProducts(var sr, String pt, String qty, String price, String total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = sr;
    row.cells[1].value = pt;
    row.cells[2].value = qty;
    row.cells[3].value = price;
    row.cells[4].value = total;
  }

  PdfLayoutResult _addParagraph(
      PdfPage page, String text, Rect bounds, bool isTitle,
      {bool mainTitle = false}) {
    return PdfTextElement(
            text: text,
            font: PdfStandardFont(
                PdfFontFamily.helvetica,
                isTitle
                    ? mainTitle
                        ? 24
                        : 18
                    : 13,
                style: (isTitle && !mainTitle)
                    ? PdfFontStyle.bold
                    : PdfFontStyle.regular),
            format: mainTitle
                ? PdfStringFormat(alignment: PdfTextAlignment.center)
                : PdfStringFormat(alignment: PdfTextAlignment.justify))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(
                bounds.left, bounds.top, bounds.width, bounds.height));
  }

  PdfBookmark _addBookmark(PdfPage page, String text, Offset point,
      {PdfDocument doc, PdfBookmark bookmark, PdfColor color}) {
    PdfBookmark book;
    if (doc != null) {
      book = doc.bookmarks.add(text);
      book.destination = PdfDestination(page, point);
    } else if (bookmark != null) {
      book = bookmark.add(text);
      book.destination = PdfDestination(page, point);
    }
    book.color = color;
    return book;
  }

  PdfLayoutResult _addTableOfContents(PdfPage page, String text, Rect bounds,
      bool isTitle, int pageNo, double x, double y, PdfPage destPage) {
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 13,
        style: isTitle ? PdfFontStyle.bold : PdfFontStyle.regular);
    page.graphics.drawString(pageNo.toString(), font,
        bounds:
            Rect.fromLTWH(480, bounds.top + 5, bounds.width, bounds.height));
    final PdfDocumentLinkAnnotation annotation = PdfDocumentLinkAnnotation(
        Rect.fromLTWH(isTitle ? bounds.left : bounds.left + 20, bounds.top - 45,
            isTitle ? bounds.width : bounds.width - 20, font.height),
        PdfDestination(destPage, Offset(x, y)));
    annotation.border.width = 0;
    page.annotations.add(annotation);
    String str = text + ' ';
    final num value = isTitle
        ? font.measureString(text).width.round() + 20
        : font.measureString(text).width.round() + 40;
    for (num i = value; i < 470;) {
      str = str + '.';
      i = i + 3.6140000000000003;
    }
    return PdfTextElement(text: str, font: font).draw(
        page: page,
        bounds: Rect.fromLTWH(isTitle ? bounds.left : bounds.left + 20,
            bounds.top + 5, bounds.width, bounds.height));
  }

  double _getTotalAmount(PdfGrid grid) {
    double total = 0;
    for (int i = 0; i < grid.rows.count; i++) {
      final String value = grid.rows[i].cells[grid.columns.count - 1].value;
      total += double.parse(value);
    }
    return total;
  }

  Future<List<int>> _readImageData(String name) async {
    final ByteData data = await rootBundle.load('images/pdf/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
