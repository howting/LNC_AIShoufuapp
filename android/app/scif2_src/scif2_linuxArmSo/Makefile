#SC�Ҳ�make��
HERE  =./
HEAD  =../head/
SRC   =../src/
EXE   =../exe_LinuxArmSo/
OBJ   =./obj/
                  
#=============================================================================
# all target
#=============================================================================
all : arm
arm       : $(EXE)libSCIF2_arm.so

#=============================================================================
# �sĶ���]�w
#============================================================================= 
CC_arm   =gcc 

#=============================================================================
# X86
#=============================================================================
CFLG_arm = -c -m32 -fPIC -I$(SRC) -I$(HERE) -I$(HEAD) -D__GCC

$(EXE)libSCIF2_arm.so : $(OBJ)sc2.o  $(OBJ)sc2_memory.o  $(OBJ)friend_client.o  $(OBJ)proc_data_talk.o  $(OBJ)proc_connect_build.o  $(OBJ)proc_sync_handle.o  $(OBJ)proc_ftp.o $(OBJ)common_function.o
	$(CC_arm) -shared   -o$@ $^
$(OBJ)sc2.o  : $(SRC)sc2.cpp 
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)sc2_memory.o  : $(SRC)sc2_memory.cpp
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)friend_client.o  : $(SRC)friend_client.cpp
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)proc_data_talk.o  : $(SRC)proc_data_talk.cpp
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)proc_connect_build.o  : $(SRC)proc_connect_build.cpp
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)proc_sync_handle.o  : $(SRC)proc_sync_handle.cpp
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)proc_ftp.o  : $(SRC)proc_ftp.cpp
	$(CC_arm) $(CFLG_arm) -o $@ $<
$(OBJ)common_function.o  : $(SRC)common_function.cpp 
	$(CC_arm) $(CFLG_arm) -o $@ $<

	
	
		

#-----------------------------------------------------------------------------
clean : 
	rm -rf  $(OBJ)*.*
	rm -rf  $(EXE)libSCIF2_arm.so
	
#-----------------------------------------------------------------------------
    
