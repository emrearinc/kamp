// lib/data/default_checklist.dart
import 'package:uuid/uuid.dart';
import 'models.dart';

final _uuid = Uuid();

List<ChecklistItem> buildDefaultChecklist() {
  int order = 0;
  final items = <ChecklistItem>[];

  void add(
      String category,
      String label, {
        bool checked = false,
        double quantity = 1,
        QuantityUnit unit = QuantityUnit.piece,
      }) {
    items.add(
      ChecklistItem(
        id: _uuid.v4(),
        category: category,
        label: label,
        quantity: quantity,
        unit: unit,
        isChecked: checked,
        sortOrder: order++,
      ),
    );
  }

  const food = '🍽 Yiyecek – İçecek';
  add(food, 'Çekirdek', );
  add(food, 'Kola', );
  add(food, 'Su', quantity: 10, unit: QuantityUnit.litre);
  add(food, 'Ekmek', quantity: 2);
  add(food, 'Simit');
  add(food, 'Yumurta', );
  add(food, 'Zeytin');
  add(food, 'Peynir');
  add(food, 'Sucuk', );
  add(food, 'Cips', );
  add(food, 'Filtre kahve', );
  add(food, 'Bira', quantity: 4);
  add(food, 'Domates – salatalık', );
  add(food, 'Yağ', quantity: 0.5, unit: QuantityUnit.litre);
  add(food, 'Çikolata / kuruyemiş');

  const kitchen = '🍳 Mutfak & Pişirme Ekipmanı';
  add(kitchen, 'Tava', );
  add(kitchen, 'Maşa', );
  add(kitchen, 'Tuz – biber', );
  add(kitchen, 'Tabak', );
  add(kitchen, 'Bıçak – çatal', );
  add(kitchen, 'Çöp poşeti');
  add(kitchen, 'Dripper', );
  add(kitchen, 'French press', );
  add(kitchen, 'Kesme tahtası', );
  add(kitchen, 'Bardak / kupa', );
  add(kitchen, 'Termos', );

  const fire = '🔥 Ateş & Isınma';
  add(fire, 'Odun – çıra', );
  add(fire, 'Kömür', );
  add(fire, 'Çakmak', );
  add(fire, 'Ateş başlatıcı jel/küp');

  const stay = '⛺ Konaklama Ekipmanı';
  add(stay, 'Yastık', );
  add(stay, 'Yatak / mat', );
  add(stay, 'Yorgan / battaniye', );
  add(stay, 'Terlik');
  add(stay, 'Çadır');
  add(stay, 'Kahvaltı sehpası');
  add(stay, 'Masa', );
  add(stay, 'Kamp sandalyesi', );
  add(stay, 'Pompa (şişme yatak varsa)', );
  add(stay, 'Tente / yağmurluk');

  const personal = '👕 Kıyafet & Kişisel';
  add(personal, 'Çorap', );
  add(personal, 'Yedek kıyafet', );
  add(personal, 'Mont / hırka', );
  add(personal, 'Islak mendil', );
  add(personal, 'Tuvalet kağıdı');
  add(personal, 'Diş fırçası & macunu');
  add(personal, 'Güneş kremi');

  const electronics = '🔦 Elektronik – Aydınlatma';
  add(electronics, 'Tablet', );
  add(electronics, 'Powerbank', );
  add(electronics, 'Şarj kabloları');
  add(electronics, 'Işıklandırma', );
  add(electronics, 'Kafa lambası', );
  add(electronics, 'Yedek pil');

  const other = '🎒 Diğer';
  add(other, 'Çakı / multitool');
  add(other, 'İlk yardım çantası');
  add(other, 'Ekstra çöp poşeti');
  add(other, 'Kürek (ateşi kapatmak için)');
  add(other, 'Oyun (iskambil, tavla vb.)');

  return items;
}
