# edit-qr.qxyz.ru project
# (c) EustroSoft.org 2020
# LICENSE: BALES,BAS,MIT on your choice
# 

PKG_PATH=org/eustrosoft/contractpkg/
PKG_SRC_ALL=${PKG_PATH}/Controller/*.java \
	${PKG_PATH}/Model/*.java ${PKG_PATH}/zcsv/*.java
PKG_CLASS_ALL=${PKG_PATH}/Controller/*.class \
	${PKG_PATH}/Model/*.class
PKG_FILENAME=QREdit
#PGSQL_JDBC_CLASSPATH?=/usr/local/share/java/classes/postgresql.jar
#SERVLET_CLASSPATH?=/usr/local/apache-tomcat4.1/common/lib/servlet.jar
CONTRIBLIB=contrib/core-3.4.0.jar:contrib/javax.servlet-api-4.0.1.jar
WORK_PATH=../../../../work/
WORKDOC_PATH=${WORK_PATH}/javadoc
INSTALL=install -m 644
RUN_CLASS=ru.mave.ConcepTIS.dao.ZSystem
JAVAC?=javac
#JAVAC=javac  -Xlint:unchecked
JAVA?=java
JAVADOC?=javadoc -private
JAR?=jar


usage:
	echo "Usage: make (build|clean|all)"
all: clean build jar

build:
	@echo "-- buildng web application and everything it's depend on"
	mkdir -p ${WORK_PATH}
	ln -s ../../../../contrib ./
	${JAVAC} -cp ${CONTRIBLIB} ${PKG_SRC_ALL}
jar:
	echo "-- packaging jar"
	${JAR} -c0f ${WORK_PATH}/${PKG_FILENAME}.jar ${PKG_CLASS_ALL}
builddoc:
	mkdir -p ${WORKDOC_PATH}
	${JAVADOC} -sourcepath ${PKG_PATH} ${PKG_SRC_ALL} -d ${WORKDOC_PATH}

clean:
clean_class:
	rm -f ${PKG_CLASS_ALL}
clean:
	@echo "-- cleaning all targets"
	-rm contrib
	rm -f ${PKG_CLASS_ALL}
	rm -rf ${WORK_PATH}/${PKG_FILENAME}.jar
