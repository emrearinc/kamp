// lib/data/default_checklist.dart
import 'package:uuid/uuid.dart';
import 'models.dart';

final _uuid = Uuid();

List<ChecklistItem> buildDefaultChecklist() {
  int order = 0;
  final items = <ChecklistItem>[];

  void add(String category, String label, {bool checked = false}) {
    items.add(
      ChecklistItem(
        id: _uuid.v4(),
        category: category,
        label: label,
        isChecked: checked,
        sortOrder: order++,
      ),
    );
  }

  const food = '🍽 Yiyecek – İçecek';
  add(food, 'Çekirdek', checked: true);
  add(food, 'Kola', checked: true);
  add(food, 'Su (10L)');
  add(food, 'Ekmek (2 adet)', checked: true);
  add(food, 'Simit');
  add(food, 'Yumurta', checked: true);
  add(food, 'Zeytin');
  add(food, 'Peynir');
  add(food, 'Sucuk', checked: true);
  add(food, 'Cips', checked: true);
  add(food, 'Filtre kahve', checked: true);
  add(food, 'Bira (4 adet)');
  add(food, 'Domates – salatalık', checked: true);
  add(food, 'Yağ (küçük)', checked: true);
  add(food, 'Çikolata / kuruyemiş');

  const kitchen = '🍳 Mutfak & Pişirme Ekipmanı';
  add(kitchen, 'Tava', checked: true);
  add(kitchen, 'Maşa', checked: true);
  add(kitchen, 'Tuz – biber', checked: true);
  add(kitchen, 'Tabak', checked: true);
  add(kitchen, 'Bıçak – çatal', checked: true);
  add(kitchen, 'Çöp poşeti');
  add(kitchen, 'Dripper', checked: true);
  add(kitchen, 'French press', checked: true);
  add(kitchen, 'Kesme tahtası', checked: true);
  add(kitchen, 'Bardak / kupa', checked: true);
  add(kitchen, 'Termos', checked: true);

  const fire = '🔥 Ateş & Isınma';
  add(fire, 'Odun – çıra', checked: true);
  add(fire, 'Kömür', checked: true);
  add(fire, 'Çakmak', checked: true);
  add(fire, 'Ateş başlatıcı jel/küp');

  const stay = '⛺ Konaklama Ekipmanı';
  add(stay, 'Yastık', checked: true);
  add(stay, 'Yatak / mat', checked: true);
  add(stay, 'Yorgan / battaniye', checked: true);
  add(stay, 'Terlik');
  add(stay, 'Çadır');
  add(stay, 'Kahvaltı sehpası');
  add(stay, 'Masa', checked: true);
  add(stay, 'Kamp sandalyesi', checked: true);
  add(stay, 'Pompa (şişme yatak varsa)', checked: true);
  add(stay, 'Tente / yağmurluk');

  const personal = '👕 Kıyafet & Kişisel';
  add(personal, 'Çorap', checked: true);
  add(personal, 'Yedek kıyafet', checked: true);
  add(personal, 'Mont / hırka', checked: true);
  add(personal, 'Islak mendil', checked: true);
  add(personal, 'Tuvalet kağıdı');
  add(personal, 'Diş fırçası & macunu');
  add(personal, 'Güneş kremi');

  const electronics = '🔦 Elektronik – Aydınlatma';
  add(electronics, 'Tablet', checked: true);
  add(electronics, 'Powerbank', checked: true);
  add(electronics, 'Şarj kabloları');
  add(electronics, 'Işıklandırma', checked: true);
  add(electronics, 'Kafa lambası', checked: true);
  add(electronics, 'Yedek pil');

  const other = '🎒 Diğer';
  add(other, 'Çakı / multitool');
  add(other, 'İlk yardım çantası');
  add(other, 'Ekstra çöp poşeti');
  add(other, 'Kürek (ateşi kapatmak için)');
  add(other, 'Oyun (iskambil, tavla vb.)');

  return items;
}
