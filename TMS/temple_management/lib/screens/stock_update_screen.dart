import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/stock_item.dart';

class StockUpdateScreen extends StatefulWidget {
  const StockUpdateScreen({super.key});

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  
  String? _selectedItem;
  
  final List<String> _itemsList = [
    "Mala 108-130",
    "Mala Gold Cap 108-150",
    "Mala 108-100",
    "Mala 54-80",
    "Mala Gold Cap 54-120",
    "Towel Mudi-80",
    "Towel Dalapati-75",
    "Panche-160",
    "Panche-180",
    "Panche kavi-250",
    "Bedsheet-180",
    "Bedsheet-200",
    "Irumudi bag-60",
    "Irumudi bag-70",
    "Side bag-130",
    "Side bag-140",
    "Side bag-100",
    "Bell-60",
    "Bell-70",
    "Photo-100",
    "Photo-130",
    "Basma-5",
    "Basma-10",
    "kunkuma-5",
    "Chandana-25",
    "Ghee Bag-10"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Update'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedItem,
                decoration: const InputDecoration(
                  labelText: 'Select Item',
                  border: OutlineInputBorder(),
                ),
                items: _itemsList.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value;
                    // Auto-fill prices for fixed-price items
                    if (value == "Ghee Bag-10") {
                      _salePriceController.text = "10";
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select an item' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Price',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Sale Price',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateStock,
                child: const Text('Update Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStock() async {
    if (!_formKey.currentState!.validate()) return;

    final stockItem = StockItem(
      itemName: _selectedItem!,
      purchasePrice: double.parse(_purchasePriceController.text),
      salePrice: double.parse(_salePriceController.text),
      stockQuantity: int.parse(_stockQuantityController.text),
    );

    try {
      await DatabaseService.updateOrCreateStockItem(stockItem);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _selectedItem = null;
      _purchasePriceController.clear();
      _salePriceController.clear();
      _stockQuantityController.clear();
    });
  }

  @override
  void dispose() {
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }
}









