class StockItem {
  final int? id;
  final String itemName;
  final double purchasePrice;
  final double salePrice;
  final int stockQuantity;
  final int itemsSold;

  StockItem({
    this.id,
    required this.itemName,
    required this.purchasePrice,
    required this.salePrice,
    required this.stockQuantity,
    this.itemsSold = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'stock_quantity': stockQuantity,
      'items_sold': itemsSold,
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'],
      itemName: map['item_name'],
      purchasePrice: map['purchase_price'],
      salePrice: map['sale_price'],
      stockQuantity: map['stock_quantity'],
      itemsSold: map['items_sold'] ?? 0,
    );
  }
}