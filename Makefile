# ConcepTIS project
# (c) Alex V Eustrop 2009
# see LICENSE at the project's root directory
# $Id$
#

PKG_PATH=org/eustrosoft/contractpkg/
PKG_SRC_ALL=${PKG_PATH}/*.java ${PKG_PATH}/Controller/*.java \
	${PKG_PATH}/Model/*.java
PKG_CLASS_ALL=${PKG_PATH}/*.class ${PKG_PATH}/Controller/*.class \
	${PKG_PATH}/Model/*.class
PKG_FILENAME=QREdit
#PGSQL_JDBC_CLASSPATH?=/usr/local/share/java/classes/postgresql.jar
#SERVLET_CLASSPATH?=/usr/local/apache-tomcat4.1/common/lib/servlet.jar
CONTRIBLIB=contrib/core-3.4.0.jar:contrib/javax.servlet-api-4.0.1.jar
WORK_PATH=work/
WORKDOC_PATH=${WORK_PATH}/javadoc
INSTALL=install -m 644
RUN_CLASS=ru.mave.ConcepTIS.dao.ZSystem
JAVAC?=javac
#JAVAC=javac  -Xlint:unchecked
JAVA?=java
JAVADOC?=javadoc -private
JAR?=jar

usage:
	@echo "Usage: make (all|build|builddoc|depend|install|run|clean)"
	@echo " where <target>:"
	@echo "  all - to do everything required"
	@echo "  build - to compile and package java classes"
	@echo "  builddoc - to construct documentation via javadoc"
	@echo "  depend - make everything this package depends on"
	@echo "  install - install something to somewhere"
	@echo "  run - to run some testing code"
	@echo "  clean - remove all constructed products"
	@echo "  usage - for this message"
#all: depend build
all:	
	cd jars/src/main/java/ && make all
	cp ${WORK_PATH}/${PKG_FILENAME}.jar webapps/EXAMPLESD/WEB-INF/lib/
	cp contrib/*jar webapps/EXAMPLESD/WEB-INF/lib/
mvn: maven
maven:
	cd jars && mvn package
	cp jars/target/jars-1.0-SNAPSHOT.jar webapps/EXAMPLESD/WEB-INF/lib/
build:
	@echo "-- buildng web application and everything it's depend on"
	mkdir -p ${WORK_PATH}
#	${JAVAC} -cp ${SERVLET_CLASSPATH} ${PKG_PATH}/*.java
	${JAVAC} -cp ${CONTRIBLIB} ${PKG_SRC_ALL}
#	${JAR} -c0fm ${WORK_PATH}/${PKG_FILENAME}.jar ${PACKAGE_MF} ${PKG_PATH}/*.class
	${JAR} -c0f ${WORK_PATH}/${PKG_FILENAME}.jar ${PKG_CLASS_ALL}
builddoc:
	mkdir -p ${WORKDOC_PATH}
	${JAVADOC} -sourcepath ${PKG_PATH} ${PKG_SRC_ALL} -d ${WORKDOC_PATH}
depend:
	@echo -- building requirements
clean_class:
	rm -f ${PKG_CLASS_ALL}
clean:
	@echo "-- cleaning all targets"
	rm -f ${PKG_CLASS_ALL}
	rm -rf work/
	rm -f webapps/EXAMPLESD/WEB-INF/lib/*.jar
install: all
	@echo !!!INTALLATION NOTICE!!!
	@echo package installed at ${WORK_PATH}/${PKG_FILENAME}.jar
	@echo javadoc results installed at ${WORKDOC_PATH}
	@echo other installation should be done by dependent webapps or end user 
	mkdir -p  ${WORK_PATH}/webapps
	mkdir -p  ${WORK_PATH}/webapps/EXAMPLESD/WEB-INF/lib
	mkdir -p  ${WORK_PATH}/webapps/DOMINATOR/WEB-INF/lib
	mkdir -p  ${WORK_PATH}/webapps/EUSTROSOFT/WEB-INF/lib
	mkdir -p  ${WORK_PATH}/webapps/rubmaster.ru/WEB-INF/lib
	mkdir -p  ${WORK_PATH}/webapps/boatswain.org/WEB-INF/lib
	mkdir -p  ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/WEB-INF/lib
	# development version of EXAMPLESD
	${INSTALL} contrib/core-3.4.0.jar webapps/EXAMPLESD/WEB-INF/lib/
	${INSTALL} work/QREdit.jar webapps/EXAMPLESD/WEB-INF/lib/
	touch webapps/EXAMPLESD/index.jsp
	#Contracts-1.0-SNAPSHOT
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/WEB-INF/web.xml ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/WEB-INF/
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/members.jsp ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/productstable.jsp ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/productview.jsp ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/ranges.jsp ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/update.jsp ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT
	mkdir -p ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/css/
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/css/webcss.css ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/css/
	${INSTALL} webapps/Contracts-1.0-SNAPSHOT/css/head.css ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/css/
	${INSTALL} contrib/core-3.4.0.jar ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/WEB-INF/lib/
	${INSTALL} work/QREdit.jar ${WORK_PATH}/webapps/Contracts-1.0-SNAPSHOT/WEB-INF/lib/
	#EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/WEB-INF/web.xml ${WORK_PATH}/webapps/EXAMPLESD/WEB-INF/
	${INSTALL} webapps/EXAMPLESD/index.jsp ${WORK_PATH}/webapps/EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/test.jsp ${WORK_PATH}/webapps/EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/members.jsp ${WORK_PATH}/webapps/EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/productstable.jsp ${WORK_PATH}/webapps/EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/productview.jsp ${WORK_PATH}/webapps/EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/ranges.jsp ${WORK_PATH}/webapps/EXAMPLESD
	${INSTALL} webapps/EXAMPLESD/update.jsp ${WORK_PATH}/webapps/EXAMPLESD
	mkdir -p ${WORK_PATH}/webapps/EXAMPLESD/css/
	${INSTALL} webapps/EXAMPLESD/css/webcss.css ${WORK_PATH}/webapps/EXAMPLESD/css/
	${INSTALL} webapps/EXAMPLESD/css/head.css ${WORK_PATH}/webapps/EXAMPLESD/css/
	${INSTALL} contrib/core-3.4.0.jar ${WORK_PATH}/webapps/EXAMPLESD/WEB-INF/lib/
	${INSTALL} work/QREdit.jar ${WORK_PATH}/webapps/EXAMPLESD/WEB-INF/lib/
	#DOMINATOR
	cp webapps/EXAMPLESD/*jsp ${WORK_PATH}/webapps/DOMINATOR
	mkdir -p ${WORK_PATH}/webapps/DOMINATOR/css/
	mkdir -p ${WORK_PATH}/webapps/DOMINATOR/lib/
	cp -r webapps/EXAMPLESD/css/*css ${WORK_PATH}/webapps/DOMINATOR/css/
	cp -r webapps/EXAMPLESD/WEB-INF/lib/*jar ${WORK_PATH}/webapps/DOMINATOR/WEB-INF/lib/
	${INSTALL} webapps/DOMINATOR/WEB-INF/web.xml ${WORK_PATH}/webapps/DOMINATOR/WEB-INF/
	#EUSTROSOFT
	cp webapps/EXAMPLESD/*jsp ${WORK_PATH}/webapps/EUSTROSOFT
	mkdir -p ${WORK_PATH}/webapps/EUSTROSOFT/css/
	mkdir -p ${WORK_PATH}/webapps/EUSTROSOFT/lib/
	cp -r webapps/EXAMPLESD/css/*css ${WORK_PATH}/webapps/EUSTROSOFT/css/
	cp -r webapps/EXAMPLESD/WEB-INF/lib/*jar ${WORK_PATH}/webapps/EUSTROSOFT/WEB-INF/lib/
	${INSTALL} webapps/EUSTROSOFT/WEB-INF/web.xml ${WORK_PATH}/webapps/EUSTROSOFT/WEB-INF/
	#rubmaster.ru
	cp webapps/EXAMPLESD/*jsp ${WORK_PATH}/webapps/rubmaster.ru
	mkdir -p ${WORK_PATH}/webapps/rubmaster.ru/css/
	mkdir -p ${WORK_PATH}/webapps/rubmaster.ru/lib/
	cp -r webapps/EXAMPLESD/css/*css ${WORK_PATH}/webapps/rubmaster.ru/css/
	cp -r webapps/EXAMPLESD/WEB-INF/lib/*jar ${WORK_PATH}/webapps/rubmaster.ru/WEB-INF/lib/
	${INSTALL} webapps/rubmaster.ru/WEB-INF/web.xml ${WORK_PATH}/webapps/rubmaster.ru/WEB-INF/
	#boatswain.org
	cp webapps/EXAMPLESD/*jsp ${WORK_PATH}/webapps/boatswain.org
	mkdir -p ${WORK_PATH}/webapps/boatswain.org/css/
	mkdir -p ${WORK_PATH}/webapps/boatswain.org/lib/
	cp -r webapps/EXAMPLESD/css/*css ${WORK_PATH}/webapps/boatswain.org/css/
	cp -r webapps/EXAMPLESD/WEB-INF/lib/*jar ${WORK_PATH}/webapps/boatswain.org/WEB-INF/lib/
	${INSTALL} webapps/boatswain.org/WEB-INF/web.xml ${WORK_PATH}/webapps/boatswain.org/WEB-INF/

run:
	${JAVA} -cp ${SERVLET_CLASSPATH}:${WORK_PATH}/${PKG_FILENAME}.jar ${RUN_CLASS}
wc:
	@wc -l Makefile ${PKG_SRC_ALL} webapps/EXAMPLESD/*jsp
