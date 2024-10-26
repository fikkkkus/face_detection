import cv2
import sys
import os

def detect_faces(image_path):
    face_cascade = cv2.CascadeClassifier('/usr/src/project/haarcascade_frontalface_default.xml')

    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(gray, 1.1, 4)

    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 0, 255), 2)

    output_path = os.path.join('/output', 'output.jpg')
    print(output_path)
    cv2.imwrite(output_path, img)

    # Р’С‹РІРѕРґРёРј РєРѕР»РёС‡РµСЃС‚РІРѕ РЅР°Р№РґРµРЅРЅС‹С… Р»РёС†
    print(f"Найдено лиц: {len(faces)}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
    else:
        image_path = '/usr/src/project/default_image.jpg'  # РЈРєР°Р¶РёС‚Рµ РёРјСЏ С„Р°Р№Р»Р° РёР·РѕР±СЂР°Р¶РµРЅРёСЏ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ
    detect_faces(image_path)