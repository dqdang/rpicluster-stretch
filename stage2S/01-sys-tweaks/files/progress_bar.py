import sys
sys.stdout.write("\r[%s%s] %s %s" % (("|||||"*int(sys.argv[1])), ("     "*int(sys.argv[2])), str(sys.argv[3]), str(sys.argv[4])))
sys.stdout.flush()




