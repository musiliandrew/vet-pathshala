import 'package:flutter/material.dart';

class PDFViewerWidget extends StatefulWidget {
  final String pdfUrl;
  final int initialPage;
  final Function(int) onPageChanged;
  final Function(int) onDocumentLoaded;

  const PDFViewerWidget({
    super.key,
    required this.pdfUrl,
    this.initialPage = 1,
    required this.onPageChanged,
    required this.onDocumentLoaded,
  });

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 1;
  int _totalPages = 100; // This would be loaded from actual PDF
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _loadPDF();
  }

  void _loadPDF() async {
    // Simulate PDF loading
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real implementation, you would use a PDF plugin like:
    // - flutter_pdfview
    // - syncfusion_flutter_pdfviewer
    // - advance_pdf_viewer
    
    setState(() {
      _isLoading = false;
      _totalPages = 150; // This would come from the PDF document
    });
    
    widget.onDocumentLoaded(_totalPages);
    
    // Jump to initial page
    if (widget.initialPage > 1) {
      _pageController.animateToPage(
        widget.initialPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page + 1;
    });
    widget.onPageChanged(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading PDF...'),
            ],
          ),
        ),
      );
    }

    // For demo purposes, we'll show placeholder pages
    // In a real app, this would be replaced with actual PDF rendering
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _totalPages,
      itemBuilder: (context, index) {
        return _buildPDFPage(index + 1);
      },
    );
  }

  Widget _buildPDFPage(int pageNumber) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Page header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Text(
                  'Veterinary Medicine Textbook',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  'Page $pageNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Page content (placeholder)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildPageContent(pageNumber),
            ),
          ),
          
          // Page footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Text(
              '$pageNumber',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int pageNumber) {
    // Generate different content for different pages
    switch (pageNumber % 5) {
      case 0:
        return _buildChapterPage(pageNumber);
      case 1:
        return _buildTextPage(pageNumber);
      case 2:
        return _buildImagePage(pageNumber);
      case 3:
        return _buildTablePage(pageNumber);
      case 4:
        return _buildDiagramPage(pageNumber);
      default:
        return _buildTextPage(pageNumber);
    }
  }

  Widget _buildChapterPage(int pageNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'Chapter ${(pageNumber ~/ 20) + 1}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Veterinary Anatomy and Physiology',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'This chapter covers the fundamental concepts of veterinary anatomy and physiology, including detailed explanations of animal body systems, their functions, and clinical applications.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTextPage(int pageNumber) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cardiovascular System',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The cardiovascular system is responsible for circulating blood throughout the body, delivering oxygen and nutrients to tissues while removing waste products. In veterinary medicine, understanding the cardiovascular system is crucial for diagnosing and treating various conditions.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Heart Structure',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The heart consists of four chambers: two atria and two ventricles. The right side of the heart pumps deoxygenated blood to the lungs, while the left side pumps oxygenated blood to the rest of the body.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Clinical Note',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Heart murmurs in animals can indicate various conditions ranging from benign to serious. Always correlate auscultation findings with clinical signs and additional diagnostic tests.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePage(int pageNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anatomical Diagram',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Heart Anatomy Diagram',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Figure ${pageNumber ~/ 10 + 1}: Cross-section of canine heart',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Figure Caption: This diagram shows the major structures of the canine heart, including the four chambers, major vessels, and valve locations.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTablePage(int pageNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Values',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Table(
          border: TableBorder.all(color: Colors.grey[300]!),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                _buildTableCell('Parameter', isHeader: true),
                _buildTableCell('Dog', isHeader: true),
                _buildTableCell('Cat', isHeader: true),
                _buildTableCell('Units', isHeader: true),
              ],
            ),
            TableRow(
              children: [
                _buildTableCell('Heart Rate'),
                _buildTableCell('70-120'),
                _buildTableCell('120-240'),
                _buildTableCell('bpm'),
              ],
            ),
            TableRow(
              children: [
                _buildTableCell('Respiratory Rate'),
                _buildTableCell('10-30'),
                _buildTableCell('20-40'),
                _buildTableCell('rpm'),
              ],
            ),
            TableRow(
              children: [
                _buildTableCell('Body Temperature'),
                _buildTableCell('37.5-39.2'),
                _buildTableCell('38.1-39.2'),
                _buildTableCell('°C'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Note: These are normal ranges for healthy adult animals. Values may vary based on breed, age, and individual factors.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDiagramPage(int pageNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDiagramBox('Brain', Colors.purple),
                const Icon(Icons.arrow_downward, color: Colors.grey),
                _buildDiagramBox('Spinal Cord', Colors.blue),
                const Icon(Icons.arrow_downward, color: Colors.grey),
                _buildDiagramBox('Peripheral Nerves', Colors.green),
                const Icon(Icons.arrow_downward, color: Colors.grey),
                _buildDiagramBox('Target Organs', Colors.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagramBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}