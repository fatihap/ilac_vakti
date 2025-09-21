class MessageService {
  // Motivasyonel mesajlar
  static const List<String> motivationalMessages = [
    'Sağlığınız için düzenli ilaç kullanımı çok önemli!',
    'İlaç takibiniz sayesinde daha sağlıklı günler geçiriyorsunuz',
    'Her doz ilaç, iyileşme yolunda bir adımdır',
    'Düzenli ilaç kullanımı sağlığınızın koruyucusudur',
    'Sağlığınız en değerli hazinenizdir',
    'İlaç takibiniz başarılı! Devam edin',
    'Sağlıklı yaşamın sırrı düzenli ilaç kullanımında',
    'Bugün de sağlığınız için doğru seçimleri yapın',
    'İlaç takibiniz sayesinde daha güçlü oluyorsunuz',
    'Sağlığınız için bugün de doğru zamanda ilaç alın',
    'Düzenli ilaç kullanımı iyileşme sürecinizi hızlandırır',
    'Sağlığınız için harika bir adım atıyorsunuz!',
    'İyileşme yolunda başarılı bir gün geçiriyorsunuz',
    'Sağlığınızın koruyucusu olarak devam edin',
    'Her ilaç alımı sağlığınıza yapılan bir yatırımdır',
    'Sağlıklı yaşam için doğru yoldasınız',
    'İlaç takibiniz sayesinde daha enerjik hissediyorsunuz',
    'Sağlığınız için mükemmel bir karar veriyorsunuz!',
    'Düzenli ilaç kullanımı sayesinde güçleniyorsunuz',
    'Sağlığınız için bugün de doğru adımları atıyorsunuz',
    'İlaç takibiniz sağlığınızın anahtarıdır',
    'Sağlığınız için düzenli olmak çok önemli!',
    'Her gün sağlığınız için doğru seçimler yapıyorsunuz!',
    'İlaç takibiniz sayesinde daha iyi hissediyorsunuz!',
    'Sağlığınız için sabırlı ve düzenli olun!',
    'İlaç takibiniz sağlığınızın temel taşıdır',
    'Düzenli ilaç kullanımı ile hayat kaliteniz artıyor',
    'Sağlığınız için her gün bir adım daha atıyorsunuz',
    'İlaç takibiniz sayesinde güçlü ve sağlıklısınız',
    'Sağlıklı yaşamın anahtarı elinizde!',
    'Her ilaç alımı iyileşme sürecinizi destekliyor',
    'Sağlığınız için doğru yoldasınız!',
    'İlaç takibiniz sayesinde daha kaliteli yaşam sürüyorsunuz',
    'Düzenli ilaç kullanımı sağlığınızın garantisidir',
    'Sağlığınız için bugün de başarılı bir gün!',
  ];

  // Tamamlama mesajları
  static const List<String> completionMessages = [
    'Tebrikler! Bugünkü ilaçlarınızı başarıyla tamamladınız!',
    'Harika! Sağlığınız için mükemmel bir gün geçirdiniz!',
    'Bravo! İlaç takibinizde bugün de başarılı oldunuz!',
    'Muhteşem! Sağlığınız için doğru seçimleri yaptınız!',
    'Tebrikler! İyileşme yolunda önemli bir adım attınız!',
    'Harika! Düzenli ilaç kullanımında başarılısınız!',
    'Bravo! Sağlığınızın koruyucusu olarak devam ediyorsunuz!',
    'Tebrikler! Sağlıklı yaşam için doğru yoldasınız!',
    'Harika! İlaç takibiniz sayesinde daha güçlüsünüz!',
    'Bravo! Sağlığınız için mükemmel bir karar verdiniz!',
    'Tebrikler! Bugün de sağlığınız için doğru seçimler yaptınız!',
    'Harika! İyileşme sürecinizde başarılı bir gün!',
    'Bravo! Sağlığınızın koruyucusu olarak devam ediyorsunuz!',
    'Tebrikler! Düzenli ilaç kullanımında mükemmelsiniz!',
    'Harika! Sağlıklı yaşam için doğru yoldasınız!',
  ];

  // Boş durum mesajları
  static const List<String> emptyStateMessages = [
    'Bu tarihte ilaç bulunmuyor, ama sağlığınız için hazırsınız!',
    'Dinlenme günü! Sağlığınız için iyi bir karar verdiniz!',
    'İlaç molası! Vücudunuz için harika bir gün!',
    'Sağlık kontrolü günü! İyi hissediyorsunuz!',
    'Dinlenme zamanı! Sağlığınız için doğru seçim!',
    'Sağlık molası! Vücudunuz için iyi bir gün!',
    'İlaç serbest günü! Sağlığınız için harika!',
    'Dinlenme günü! Sağlığınız için doğru karar!',
    'Sağlık kontrolü! İyi hissediyorsunuz!',
    'İlaç molası! Vücudunuz için mükemmel bir gün!',
  ];

  // Greeting mesajları
  static const List<String> greetingMessages = [
    'Günaydın',
    'İyi günler',
    'İyi akşamlar',
    'İyi geceler',
  ];

  // Sağlık mesajları (ana sayfa için)
  static const List<String> healthMessages = [
    'Sağlığınız için bugün de düzenli ilaç almayı unutmayın!',
    'İlaç takibiniz sağlığınızın anahtarıdır',
    'Düzenli ilaç kullanımı iyileşme sürecinizi hızlandırır',
    'Bugün de sağlığınız için doğru adımları atın',
    'İlaç takibiniz sayesinde daha sağlıklı günler geçiriyorsunuz',
    'Sağlığınız en değerli hazinenizdir',
    'Düzenli ilaç kullanımı sağlığınızın koruyucusudur',
    'Her doz ilaç, sağlığınıza bir adım daha yaklaştırır',
    'Sağlığınız için bugün de doğru zamanda ilaç alın',
    'İlaç takibiniz başarılı! Sağlığınız için devam edin',
    'Sağlıklı yaşamın sırrı düzenli ilaç kullanımında',
    'Bugün de sağlığınız için doğru seçimleri yapın',
    'Sağlığınız için düzenli olmak çok önemli!',
    'Her gün sağlığınız için doğru seçimler yapıyorsunuz!',
    'İlaç takibiniz sayesinde daha iyi hissediyorsunuz!',
  ];

  // Sabah mesajları
  static const List<String> morningMessages = [
    'Sabah ilaçlarınızı almayı unutmayın!',
    'Güne sağlıklı başlamak için ilaçlarınızı alın',
    'Sabah rutininizin önemli bir parçası: İlaçlarınız',
    'Günaydın! Sağlığınız için ilaçlarınızı almayı unutmayın',
    'Sabah ilaçlarınızla güne başlayın!',
    'Sağlıklı bir gün için sabah ilaçlarınızı alın',
    'Sabah ilaçlarınızla enerji dolu bir gün geçirin!',
    'Güne sağlıklı başlamak için ilaçlarınızı alın!',
    'Sabah rutininizde ilaç takibinizi unutmayın!',
    'Sağlıklı bir gün için sabah ilaçlarınızı alın!',
    'Sabah ilaçlarınızla güne güçlü başlayın!',
    'Günaydın! Sağlığınız için ilaçlarınızı alın!',
    'Sabah ilaçlarınızla sağlıklı bir gün geçirin!',
    'Güne sağlıklı başlamak için ilaçlarınızı almayı unutmayın!',
    'Sabah ilaçlarınızla enerji dolu bir gün!',
  ];

  // Öğle mesajları
  static const List<String> afternoonMessages = [
    'Öğle ilaçlarınızı almayı unutmayın!',
    'Gün ortası ilaç takibiniz nasıl gidiyor?',
    'Sağlığınız için öğle ilaçlarınızı alın',
    'Öğle ilaçlarınızla enerjinizi koruyun!',
    'Gün ortası sağlık kontrolü! İlaçlarınızı alın',
    'Öğle ilaçlarınızla günün devamını sağlıklı geçirin!',
    'Gün ortası ilaç takibinizde başarılısınız!',
    'Öğle ilaçlarınızı almayı unutmayın!',
    'Sağlığınız için öğle ilaçlarınızı alın!',
    'Gün ortası ilaç takibiniz sağlığınızın anahtarı!',
    'Öğle ilaçlarınızla enerji dolu devam edin!',
    'Sağlıklı öğle rutininiz için ilaçlarınızı alın!',
    'Gün ortası ilaç takibinizde mükemmelsiniz!',
    'Öğle ilaçlarınızla güçlü devam edin!',
    'Sağlığınız için öğle ilaçlarınızı almayı unutmayın!',
  ];

  // Akşam mesajları
  static const List<String> eveningMessages = [
    'Akşam ilaçlarınızı almayı unutmayın!',
    'Günün sonunda sağlığınız için ilaçlarınızı alın',
    'Akşam rutininizde ilaç takibinizi tamamlayın',
    'Akşam ilaçlarınızla günü sağlıklı bitirin!',
    'Günü sağlıklı bir şekilde bitirin! İlaçlarınızı alın',
    'Akşam ilaçlarınızla günü tamamlayın!',
    'Akşam ilaçlarınızla sağlıklı bir akşam geçirin!',
    'Günün sonunda ilaç takibinizi tamamlayın!',
    'Akşam ilaçlarınızla güçlü bir gün bitirin!',
    'Sağlıklı akşam rutininiz için ilaçlarınızı alın!',
    'Akşam ilaçlarınızla enerji dolu bir akşam!',
    'Günün sonunda sağlığınız için ilaçlarınızı almayı unutmayın!',
    'Akşam ilaçlarınızla sağlıklı bir gün bitirin!',
    'Günü sağlıklı bir şekilde tamamlayın! İlaçlarınızı alın',
    'Akşam ilaçlarınızla günü mükemmel bitirin!',
  ];

  // Gece mesajları
  static const List<String> nightMessages = [
    'Gece ilaçlarınızı almayı unutmayın!',
    'Uyumadan önce son ilaçlarınızı alın',
    'Gece ilaç takibiniz sağlığınız için önemli',
    'Gece ilaçlarınızla sağlıklı uyuyun!',
    'Gece rutininizin önemli bir parçası: İlaçlarınız',
    'Uyumadan önce son ilaçlarınızı almayı unutmayın!',
    'Gece ilaç takibiniz sağlığınızın koruyucusudur',
    'Sağlıklı uyku için gece ilaçlarınızı alın',
    'Gece ilaçlarınızla günü tamamlayın!',
    'Uyumadan önce son ilaçlarınızı alın!',
    'Gece ilaç takibiniz sağlığınız için kritik!',
    'Sağlıklı gece rutininiz için ilaçlarınızı alın',
    'Gece ilaçlarınızla güçlü uyuyun!',
    'Uyumadan önce son ilaçlarınızı almayı hatırlayın!',
    'Gece ilaç takibiniz sağlığınızın anahtarıdır',
  ];

  // Başarı mesajları (ilaç aldım için)
  static const List<String> successMessages = [
    'Sağlığınız için harika bir adım!',
    'İyileşme yolunda bir adım daha attınız',
    'Sağlıklı yaşam için doğru seçim!',
    'Düzenli ilaç kullanımı sayesinde güçleniyorsunuz',
    'Sağlığınız için mükemmel bir karar!',
    'İlaç takibiniz sayesinde daha sağlıklısınız',
    'Her doz ilaç sağlığınıza yapılan bir yatırım',
    'Sağlığınızın koruyucusu olarak devam edin',
    'İyileşme sürecinizde başarılı bir adım!',
    'Sağlıklı yaşam için doğru yoldasınız',
    'Sağlığınız için doğru adım attınız!',
    'İlaç takibinizde başarılısınız!',
    'Sağlığınız için harika bir karar!',
    'Düzenli ilaç kullanımında mükemmelsiniz!',
    'Sağlıklı yaşam için doğru seçim!',
  ];

  // Motivasyon mesajları (dialog için)
  static const List<String> dialogMotivationalMessages = [
    'Sağlığınız için doğru adım atıyorsunuz!',
    'Düzenli ilaç kullanımı iyileşmenizi hızlandırır',
    'Her doz ilaç sağlığınıza yapılan bir yatırımdır',
    'Sağlıklı yaşamın sırrı düzenli ilaç kullanımında',
    'İlaç takibiniz sayesinde daha güçlü oluyorsunuz',
    'Sağlığınız için bugün de doğru seçim yaptınız',
    'Düzenli ilaç kullanımı sağlığınızın koruyucusudur',
    'Her ilaç alımı iyileşme yolunda bir adımdır',
    'Sağlığınız en değerli hazinenizdir',
    'İlaç takibiniz başarılı! Devam edin',
  ];

  // Feedback mesajları (pozitif)
  static const List<String> positiveFeedbackMessages = [
    'Harika! Sağlığınız için doğru adım!',
    'Mükemmel! İlaç takibinizde başarılısınız!',
    'Tebrikler! Sağlığınız için doğru seçim!',
    'Bravo! İyileşme yolunda bir adım daha!',
    'Harika! Düzenli ilaç kullanımında başarılısınız!',
    'Tebrikler! Sağlığınız için mükemmel bir karar!',
    'Bravo! İlaç takibinizde başarılısınız!',
    'Harika! Sağlığınız için doğru adım!',
    'Tebrikler! Düzenli ilaç kullanımında mükemmelsiniz!',
    'Bravo! Sağlıklı yaşam için doğru seçim!',
  ];

  // Feedback mesajları (negatif)
  static const List<String> negativeFeedbackMessages = [
    'Sorun değil! Daha sonra alabilirsiniz',
    'Unutmayın, sağlığınız için önemli!',
    'Zamanında almanız sağlığınız için iyi olur',
    'İlaç takibinizde dikkatli olun!',
    'Sağlığınız için hatırlamaya çalışın!',
    'Sorun değil! Sağlığınız için hatırlayın!',
    'Unutmayın, düzenli alım çok önemli!',
    'Sağlığınız için zamanında almayı deneyin!',
    'İlaç takibinizde dikkatli olun!',
    'Sağlığınız için hatırlamaya çalışın!',
  ];

  // Selamlama için basit iconlar (Emoji'ler kaldırıldı - artık FontAwesome kullanılacak)
  // Bu liste artık kullanılmıyor, selamlama için sadece metin kullanılıyor

  // Gelişmiş rastgele seçim algoritması
  static int _getRandomIndex(List<String> messages, {String? extraSeed}) {
    final now = DateTime.now();
    // Çoklu faktör kullanarak gerçek rastgelelik sağla
    final seed = now.millisecondsSinceEpoch + 
                now.microsecondsSinceEpoch + 
                now.day + 
                now.hour + 
                now.minute + 
                now.second + 
                now.millisecond + 
                (extraSeed?.hashCode ?? 0);
    
    // Modulo işlemi ile index hesapla
    return seed.abs() % messages.length;
  }

  // Mesaj alma metodları
  static String getMotivationalMessage() {
    final index = _getRandomIndex(motivationalMessages, extraSeed: 'motivational');
    return motivationalMessages[index];
  }

  static String getCompletionMessage() {
    final index = _getRandomIndex(completionMessages, extraSeed: 'completion');
    return completionMessages[index];
  }

  static String getEmptyStateMessage() {
    final index = _getRandomIndex(emptyStateMessages, extraSeed: 'empty');
    return emptyStateMessages[index];
  }

  static String getHealthMessage() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      final index = _getRandomIndex(morningMessages, extraSeed: 'morning');
      return morningMessages[index];
    } else if (hour >= 12 && hour < 17) {
      final index = _getRandomIndex(afternoonMessages, extraSeed: 'afternoon');
      return afternoonMessages[index];
    } else if (hour >= 17 && hour < 21) {
      final index = _getRandomIndex(eveningMessages, extraSeed: 'evening');
      return eveningMessages[index];
    } else {
      final index = _getRandomIndex(nightMessages, extraSeed: 'night');
      return nightMessages[index];
    }
  }

  static String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return greetingMessages[0];
    } else if (hour >= 12 && hour < 17) {
      return greetingMessages[1];
    } else if (hour >= 17 && hour < 21) {
      return greetingMessages[2];
    } else {
      return greetingMessages[3];
    }
  }

  // Bu metod artık kullanılmıyor - emoji'ler kaldırıldı
  @deprecated
  static String getGreetingEmoji() {
    return ''; // Boş string dönüyor
  }

  static String getSuccessMessage() {
    final index = _getRandomIndex(successMessages, extraSeed: 'success');
    return successMessages[index];
  }

  static String getDialogMotivationalMessage() {
    final index = _getRandomIndex(dialogMotivationalMessages, extraSeed: 'dialog');
    return dialogMotivationalMessages[index];
  }

  static String getPositiveFeedbackMessage() {
    final index = _getRandomIndex(positiveFeedbackMessages, extraSeed: 'positive');
    return positiveFeedbackMessages[index];
  }

  static String getNegativeFeedbackMessage() {
    final index = _getRandomIndex(negativeFeedbackMessages, extraSeed: 'negative');
    return negativeFeedbackMessages[index];
  }
}
