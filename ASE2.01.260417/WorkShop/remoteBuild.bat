plink -ssh administrator@192.168.0.7 -pwfile D:/ASE/ASE-2/ASEProject/WorkShop/passWordFile -batch "rm -r /home/administrator/projects/ASETarget/Slx2Rtw/Include"
plink -ssh administrator@192.168.0.7 -pwfile D:/ASE/ASE-2/ASEProject/WorkShop/passWordFile -batch "rm -r /home/administrator/projects/ASETarget/Slx2Rtw/Src"
plink -ssh administrator@192.168.0.7 -pwfile D:/ASE/ASE-2/ASEProject/WorkShop/passWordFile -batch "rm -r /home/administrator/projects/ASETarget/build"
pscp -pwfile D:/ASE/ASE-2/ASEProject/WorkShop/passWordFile -r D:/ASE/ASE-2/ASEProject/Demo/uartDemo_ert_rtw/Include administrator@192.168.0.7:/home/administrator/projects/ASETarget/Slx2Rtw
pscp -pwfile D:/ASE/ASE-2/ASEProject/WorkShop/passWordFile -r D:/ASE/ASE-2/ASEProject/Demo/uartDemo_ert_rtw/Src administrator@192.168.0.7:/home/administrator/projects/ASETarget/Slx2Rtw
plink -ssh administrator@192.168.0.7 -pwfile D:/ASE/ASE-2/ASEProject/WorkShop/passWordFile -batch "mkdir -p /home/administrator/projects/ASETarget/build; cd /home/administrator/projects/ASETarget/build; rm -r *; cmake ..; make"
