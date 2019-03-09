import numpy as np 
import os  
import points2dist
import datetime

############################################
############ python批量更换后缀名   #########
###列出当前目录下所有的文件
#files = os.listdir('.')
#print('files',files)
#for filename in files:
#    portion = os.path.splitext(filename)
#    # 如果后缀是.dat
#    if portion[1] == ".dat":  
#        # 重新组合文件名和后缀名
#        newname = portion[0] + ".txt"   
#        os.rename(filename,newname)

#track = np.loadtxt('./track.txt') 
#n = np.loadtxt('./n.txt') 
#cyc = np.loadtxt('./cyc.txt') 
j1 = np.loadtxt('./j1.txt') 
lon_eddy = np.loadtxt('./lon_eddy.txt') 
lat_eddy = np.loadtxt('./lat_eddy.txt') 
R = np.loadtxt('./R.txt') 
#A = np.loadtxt('./A.txt') 
#U = np.loadtxt('./U.txt') 
#print(R[0])

match_num = np.ones(23086878)
match_num = match_num*-1
#print(match_num[0])

starttime = datetime.datetime.now()

for i in range(23086878):


    if lon_eddy[i]>=357.5 and lon_eddy[i]<=360:
        it_near = (np.where( ( lat_eddy > lat_eddy[i]-2.5 ) & ( lat_eddy < lat_eddy[i]+2.5 ) 
                    & ( lon_eddy < lon_eddy[i]+2.5-360 ) & ( lon_eddy > lon_eddy[i]-2.5 ) & (j1 == j1[i]) )[0])
    elif lon_eddy[i]>=0 and lon_eddy[i]<=2.5:
        it_near = (np.where( ( lat_eddy > lat_eddy[i]-2.5 ) & ( lat_eddy < lat_eddy[i]+2.5 ) 
                    & ( lon_eddy < lon_eddy[i]+2.5 ) & ( lon_eddy > lon_eddy[i]+360-2.5 ) & (j1 == j1[i]) )[0])     
    else:
        it_near = (np.where( ( lat_eddy > lat_eddy[i]-2.5)  &  (lat_eddy < lat_eddy[i]+2.5 ) 
                    & ( lon_eddy < lon_eddy[i]+2.5 )  & ( lon_eddy > lon_eddy[i]-2.5 )  & (j1 == j1[i]) )[0] )
    it_self = np.where(it_near == i)[0]
    it_near_noself = np.delete(it_near,it_self)

    xx = lat_eddy[it_near_noself]
    yy = lon_eddy[it_near_noself]
    it_usenum = np.size(it_near_noself)

    match_use_cache = (points2dist.points2dist(it_usenum, lat_eddy[i], xx, lon_eddy[i], yy , R[i], R[it_near_noself] ))

    it_useful = np.where(match_use_cache>0)[0]
    if len(it_useful)>0:                                               ####### 有配对结果
        match_cache = match_num[it_near_noself[it_useful]]             ####### 配对序列筛出 
        it_match_never = np.where(match_cache<0)[0]                    ####### 配对结果未被配过部分
        it_match_ever = np.where(match_cache>=0)[0]                    ####### 配对结果曾被配过部分

        if match_num[i]<0 and len(it_match_never)==len(match_cache):   ####### 本体未配 & 配对都未配
            match_num[i] = i
            match_num[it_near_noself[it_useful]] = i

        elif match_num[i]<0 and len(it_match_never)<len(match_cache):  ####### 本体未配 & 配对部分未配或已全配
            min_match_num = min(match_cache[it_match_ever])
            match_num[i] = min_match_num
            for n in range(len(it_match_ever)):                             ####### 过去已配对的连成一条
                it_history = np.where(match_num==match_cache[it_match_ever[n]])[0]
                match_num[it_history] = min_match_num
            match_num[it_near_noself[it_useful]] = min_match_num       ####### 若部分未配/全配 均刷新

        elif match_num[i]>=0 and len(it_match_never)==len(match_cache):####### 本体已配 & 配对都未配
            match_num[it_near_noself[it_useful]] = match_num[i]

        elif match_num[i]>=0 and len(it_match_never)<len(match_cache): ####### 本体已配 & 配对部分未配或已全配
            min_match_num = min(np.append(match_cache[it_match_ever],match_num[i]))
            for n in range(len(it_match_ever)):                             ####### 过去已配对的连成一条
                it_history = np.where(match_num==match_cache[it_match_ever[n]])[0]
                match_num[it_history] = min_match_num
            match_num[it_near_noself[it_useful]] = min_match_num       ####### 若部分未配/全配 均刷新  
            it_match_self = np.where(match_num==match_num[i])[0]     
            match_num[it_match_self] = min_match_num                   ####### 本体及本体相同的均刷新
    if i%1000000==0 and i>0:
        endtime = datetime.datetime.now()
        print (endtime - starttime)
        output1 = open('./match_num_'+ str(i) +'.txt','w')
        for j in range(23086878):
            output1.write("%10d" % (match_num[j]))
            output1.write("\n")
        output1.close()

output = open('./match_num.txt','w')
for i in range(23086878):
    output.write("%10d" % (match_num[i]))
    output.write("\n")
output.close()


#f=open('test.txt','w')
#for i in range(4): 
#    f.write("%6d" % (tx[i]) ) 
#    f.write("\n") 
#f.close()



    
      
