import cv2
import sys

def detect_faces(image_path):
    # Загружаем каскадный классификатор для обнаружения лиц
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

    # Загружаем изображение
    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Обнаруживаем лица
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)

    # Рисуем прямоугольники вокруг обнаруженных лиц
    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 0, 255), 2)

    # Сохраняем результат
    cv2.imwrite('output.jpg', img)

    # Выводим количество найденных лиц
    print(f"Найдено лиц: {len(faces)}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
    else:
        image_path = 'default_image.jpg'  # Укажите имя файла изображения по умолчанию
    detect_faces(image_path)
