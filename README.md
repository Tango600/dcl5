DCL5 -- представляет скриптовый, интерпретируемый язык, для создания интерфейса
приложения использующего какую-либо СУБД. Он описывает, что должен содержать
диалог, какие действия будут производиться при нажатии описанных кнопок.

При написании приложений на этом языке Вам не надо заботиться о размещении и
компоновке визуальных элементов форм, это за Вас сделает сам DCL5.

Основная часть бизнес-логики, должна быть реализована средствами самой СУБД и её
хранимыми процедурами, триггерами и т.д.

Концепция DCL5, в том, что используя ограниченный набор специальных визуальных
компонент, создать полноценное бизнес-приложение, притом, эти компоненты
являются макро-компонентами, включающими несколько сложных действий, порою,
скрытых от разработчика, дабы не отягчать его излишней черновой работой, из
которых подобно блокам складывается интерфейс приложения.

Кроме интерфейсной части, язык содержит в себе средства манипуляции данных и
организации простой бизнес-логики.

Код, который оперирует визуальными компонентами, отделён от кода манипуляции
данных и бизнес-логики, хотя это не строгое разделение.

Проект переехал на https://gitflic.ru/project/dcl5/dclplatform/
