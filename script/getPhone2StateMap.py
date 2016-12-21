import sys
SIL_SET={"int", "pau", "spk"}

def append_dim(num, dim_count, dim_list):
    for i in range(num):
        dim_list.append(dim_count)
        dim_count += 1

if __name__=="__main__":
    if len(sys.argv) < 3:
        print("USAGE: " + sys.argv[0] + " phone_list phone_2_state_map\n")
        exit(1)

    phone_list = open(sys.argv[1]).readlines()
    fid = open(sys.argv[2], "w")

    dim_count=0
    phone_2_state_map = [[]]
    for phone in phone_list:
        if(phone.strip() in SIL_SET):
            append_dim(3, dim_count, phone_2_state_map[0])
            dim_count += 3
        else:
            phone_2_state_map.append([])
            append_dim(3, dim_count, phone_2_state_map[-1])
            dim_count += 3
    for i in range(len(phone_2_state_map)):
        for j in range(len(phone_2_state_map[i])):
            fid.write("%d %d\n" % (i, phone_2_state_map[i][j]))
    fid.close()
