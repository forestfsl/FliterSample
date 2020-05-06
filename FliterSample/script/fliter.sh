#传入二进制的名字
param_dir="$1"
#进入目录
cd $param_dir
param_macho=${param_dir%.*}
param_macho=${param_macho##*/}
#echo $param_macho

param_fliter="$2"

#遍历查询
nm $param_macho | grep -i -r --color=auto $param_fliter
for framework in Frameworks/*.framework; do
  fname=$(basename $framework .framework)
 # echo $fname
  nm $framework/$fname | grep -i -r --color=auto $param_fliter
done
