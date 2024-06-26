//
//  Functions.swift
//  MemoriaFlora
//
//  Created by ImranAftab on 4/19/24.
//

import Foundation
import UIKit

func animateTransition(to viewController: UIViewController, view: UIView) {
    UIApplication.shared.windows.first?.rootViewController = viewController
}

func createCondolencesEmail(recipientName: String, purchaserName: String, flowerName: String) -> String {
    switch DefaultManager.getAppLanguage() {
    case "en":
        return createCondolencesEmailEN(recipientName: recipientName, purchaserName: purchaserName, flowerName: flowerName)
    case "es":
        return createCondolencesEmailES(recipientName: recipientName, purchaserName: purchaserName, flowerName: flowerName)
    case "it":
        return createCondolencesEmailIT(recipientName: recipientName, purchaserName: purchaserName, flowerName: flowerName)
    case "fr":
        return createCondolencesEmailFR(recipientName: recipientName, purchaserName: purchaserName, flowerName: flowerName)
    case "pt":
        return createCondolencesEmailPT(recipientName: recipientName, purchaserName: purchaserName, flowerName: flowerName)
    default:
        return createCondolencesEmailEN(recipientName: recipientName, purchaserName: purchaserName, flowerName: flowerName)
    }

}

func createCondolencesEmailEN(recipientName: String, purchaserName: String, flowerName: String) -> String {

    let emailBody = """
    Dear \(recipientName),

    We wanted to share with you a heartwarming gesture made by \(purchaserName). They have just purchased a beautiful bouquet of \(flowerName) from our app, intending to honor and remember your loved departed person.

    It is a touching expression of sympathy and support during this difficult time. We hope that this small gesture brings some comfort to you and your family.

    Please know that our thoughts are with you, and we are here for you if you need anything.

    With heartfelt condolences,
    Free Future Lda
    +393348432194
    www.freefuture.eu
    """

    return emailBody
}

func createCondolencesEmailPT(recipientName: String, purchaserName: String, flowerName: String) -> String {

    let emailBody = """
    Caro/a \(recipientName),

    Queríamos compartilhar com você um gesto comovente feito por \(purchaserName). Eles acabaram de comprar um lindo buquê de \(flowerName) pelo nosso aplicativo, com a intenção de honrar e lembrar do seu ente querido falecido.

    É uma expressão tocante de simpatia e apoio durante este momento difícil. Esperamos que este pequeno gesto traga algum conforto para você e sua família.

    Por favor, saiba que nossos pensamentos estão com você, e estamos aqui para você se precisar de alguma coisa.

    Com sinceras condolências,
    Free Future Lda
    +393348432194
    www.freefuture.eu
    """

    return emailBody
}

func createCondolencesEmailFR(recipientName: String, purchaserName: String, flowerName: String) -> String {

    let emailBody = """
    Cher/Chère \(recipientName),

    Nous voulions partager avec vous un geste réconfortant fait par \(purchaserName). Ils viennent d'acheter un magnifique bouquet de \(flowerName) depuis notre application, dans l'intention d'honorer et de se souvenir de votre être cher disparu.

    C'est une expression touchante de sympathie et de soutien en cette période difficile. Nous espérons que ce petit geste apportera un peu de réconfort à vous et à votre famille.

    Sachez que nos pensées sont avec vous, et nous sommes là pour vous si vous avez besoin de quoi que ce soit.

    Avec nos sincères condoléances,
    Free Future Lda
    +393348432194
    www.freefuture.eu
    """

    return emailBody
}

func createCondolencesEmailIT(recipientName: String, purchaserName: String, flowerName: String) -> String {

    let emailBody = """
    Caro/a \(recipientName),

    Volevamo condividere con te un gesto commovente fatto da \(purchaserName). Hanno appena acquistato un bellissimo bouquet di \(flowerName) dalla nostra app, con l'intenzione di onorare e ricordare la tua persona amata scomparsa.

    È un'espressione toccante di simpatia e sostegno in questo momento difficile. Speriamo che questo piccolo gesto porti un po' di conforto a te e alla tua famiglia.

    Per favore, sappi che i nostri pensieri sono con te, e siamo qui per te se hai bisogno di qualcosa.

    Con sincere condoglianze,
    Free Future Lda
    +393348432194
    www.freefuture.eu
    """

    return emailBody
}

func createCondolencesEmailES(recipientName: String, purchaserName: String, flowerName: String) -> String {

    let emailBody = """
    Querido/a \(recipientName),

    Queríamos compartir contigo un gesto conmovedor realizado por \(purchaserName). Acaban de comprar un hermoso ramo de \(flowerName) desde nuestra aplicación, con la intención de honrar y recordar a tu ser querido fallecido.

    Es una expresión conmovedora de simpatía y apoyo durante este difícil momento. Esperamos que este pequeño gesto brinde algo de consuelo a ti y a tu familia.

    Por favor, ten en cuenta que nuestros pensamientos están contigo, y estamos aquí para ti si necesitas algo.

    Con sinceras condolencias,
    Free Future Lda
    +393348432194
    www.freefuture.eu
    """

    return emailBody
}

func getCondolenceMessage(nameLabel: String, link: String) -> String {
    switch DefaultManager.getAppLanguage() {
    case "en":
        return """
        🌹 In loving memory of \(nameLabel), let's honor their memory together. Please join me in paying tribute by offering flowers. \n\(link) \n#InMemory #ForeverInOurHearts 🌹
        """
    case "es":
        return """
        🌹 En memoria amorosa de \(nameLabel), honremos su memoria juntos. Por favor, únase a mí para rendir homenaje ofreciendo flores. \n\(link) \n#EnMemoria #PorSiempreEnNuestrosCorazones 🌹
        """
    case "it":
        return """
        🌹 In memoria affettuosa di \(nameLabel), onoriamo insieme la loro memoria. Per favore, unisciti a me nel rendere omaggio offrendo fiori. \n\(link) \n#InMemoria #PerSempreNeiNostriCuori 🌹
        """
    case "fr":
        return """
        🌹 En mémoire affectueuse de \(nameLabel), honorons ensemble leur mémoire. Veuillez vous joindre à moi pour rendre hommage en offrant des fleurs. \n\(link) \n#EnMémoire #ÀJamaisDansNosCœurs 🌹
        """
    case "pt":
        return """
        🌹 Em memória amorosa de \(nameLabel), vamos honrar sua memória juntos. Por favor, junte-se a mim para prestar homenagem oferecendo flores. \n\(link) \n#EmMemória #ParaSempreEmNossosCorações 🌹
        """
    default:
        return """
        🌹 In loving memory of \(nameLabel), let's honor their memory together. Please join me in paying tribute by offering flowers. \n\(link) \n#InMemory #ForeverInOurHearts 🌹
        """
    }
}
