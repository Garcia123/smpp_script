#!/bin/bash

. /etc/rc.d/init.d/functions

DIRNAME=$(dirname $0);
DEMON_HOME=$(cd $DIRNAME/..;pwd -LP);
PROCNAME=$(echo $DEMON_HOME | awk -F"/" '{print $NF}');

respuesta=0;

lib="$DEMON_HOME/lib";
etc="$DEMON_HOME/etc";
log="$DEMON_HOME/var/log";
pid="$DEMON_HOME/var/run";
exe="/usr/bin/jsvc";
name="";

USER="root";

#JAVA_HOME="/usr/lib/jvm/jre-1.8.0-openjdk";
JAVA_HOME="/usr/java/jdk1.8.0_144";
CLASS_PATH="$lib/deamon.jar:$lib/*";
CLASS="org.atiperu.daemon.DaemonApp2";
ARGS="";
# -cwd $DEMON_HOME;

function jvsc_exec(){
  local flag="$1";
  $exe -procname $PROCNAME $flag -cp $CLASS_PATH -java-home $JAVA_HOME -user $USER -pidfile $pid/$PROCNAME.pid -outfile $log/$PROCNAME.out -errfile $log/$PROCNAME.err $CLASS $ARGS;
  echo $?;
}

function iniciando_proceso(){
  
  if [[ -f "$pid/$PROCNAME.pid" ]]; then
    
    local mens=$"se encontro un archivo pid: ";
    echo -n "$mens";
    sleep 1;
    failure "$mens";
    echo
    respuesta=1;

  else

    respuesta=$(jvsc_exec);

    if [[ $respuesta == 1 ]]; then
      
      local mens=$"se encontro problemas al iniciar: ";
      echo -n "$mens";
      sleep 1
      failure "$mens";
      echo
      respuesta=1;
    else
      
      local mens=$"iniciando servicio $PROCNAME: ";
      echo -n "$mens";
      sleep 1
      success "$mens";
      echo
    
    fi

  fi
  
}

function deteniendo_proceso(){
  echo -n $"Deteniendo proceso $PROCNAME: ";
  local ret=$(jvsc_exec "-stop");

  if [[ $ret -eq 0 ]]; then
    echo_success;
  else
    echo_failure;
    respuesta=1;
  fi
  echo
}

function estado_proceso(){
  status -p $pid/$PROCNAME.pid $PROCNAME;
  respuesta=$?;
}


function main(){

  local flag="$1";

  case $flag in
    start )
      iniciando_proceso;
    ;;
    stop )
      deteniendo_proceso
    ;;
    status )
        estado_proceso
    ;;
    * )
        echo "usar: $DEMON_HOME/util/smpp_client.sh {start|stop|status}" >&2;
      ;;
  esac
}

main $1;

exit $respuesta;
