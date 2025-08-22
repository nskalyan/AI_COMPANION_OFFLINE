## Companion app

# Steps to set up and run 
1) Clone the repoisitory- git clone https://github.com/nskalyan/AI_COMAPNION_OFFLINE
2) cd companion_backend
3) backend\Scripts\activate (if windows) or source .backend/bin/activate (macOs/linux)
4) pip install -r requirements.txt
5) uvicorn main.app:app --reload  (you can specify like ip 0.0.0.0 for listening all network interfaces) or **uvicorn app.main:app --reload --host 0.0.0.0 --port 8000**
 ## if you debug offline in phone
1) open phone and turn on developer options and on usb debugging and connect phone to system via a stable usb
2) open new terminaland type  cd comapnion_flutter
3) flutter pub get
4) flutter devices  # here verify your device name is there and verified if not verified accpep rsa in your when we connect via usb
5) flutter run
6) you can be able to see the app make changes and modify too



 # Tech stack 
 Languages:-Python,Dart <br>
 Frameworks:-Flutter <br>
 Tools:-Ollama (run running the model offline) <br>

 # output 
can be delivered as apk file (flutter build apk --anyname)

# contributors 
1)NS KALYAN <br>
2)Ch Surya Kumari <br>
3)M Lakshmi Chandana  <br>

for any queries:nunna.srinivaskalyan@gmail.com


