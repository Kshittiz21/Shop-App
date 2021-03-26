import java.util.*;
import java.*;

class rev_name extends Thread {
    public String strArray[];
    public rev_name(String[] strArray) {
        this.strArray = strArray;
    }

    @Override
    public void run() {
        System.out.println("\n");
        for (int i = 2; i >= 0; i--) {
            System.out.print(strArray[i] + " ");
        }
        System.out.println("\n");
    }
}

class print_perm extends Thread {
    public String Name;
    public print_perm(String Name) {
        this.Name = Name;
    }

    @Override
    public void run() {
        int[] PArray = new int[Name.length() + 1];
        PArray[0] = 1;
        for (int i = 1; i <= Name.length(); i++) {
            PArray[i] = PArray[i - 1] * i;
        }

        for (int i = 0; i < PArray[Name.length()]; i++) {
            String P1 = "";
            String temp = Name;
            int PosCode = i;
            for (int pos = Name.length(); pos > 0; pos--) {
                int selected = PosCode / PArray[pos - 1];

                P1 += temp.charAt(selected);
                PosCode = PosCode % PArray[pos - 1];
                temp = temp.substring(0, selected) + temp.substring(selected + 1);

            }
            System.out.print(P1 + " ");
        }
        System.out.println("\n");
    }
}


class rearrange_name extends Thread {
    public String full_name;
    public int D;

    public rearrange_name(String FullName, int d) {
        this.full_name = FullName;
        this.D = d;
    }

    @Override
    public void run() {
        int Len = full_name.length(), i, j, m = 0, n = 0, count = 0, flag = 0;

        char[] arr = new char[Len];
        for (i = 0; i < Len; i++) {
            arr[i] = full_name.charAt(i);
        }

        char[] rep = new char[Len];

        char[] non_rep = new char[Len];

        int[] counted = new int[Len];

        for (i = 0; i < Len; i++) {
            char Ch = arr[i];
            for (j = i + 1; j < Len; j++) {
                if (Ch == arr[j]) {
                    count++;
                }
            }
            if (count > 0) {
                for (j = 0; j < Len; j++) {
                    if (Ch == rep[j])
                        flag = 1;
                }
                if (flag == 0) {
                    rep[m] = Ch;
                    m++;
                }
                flag = 0;
            } else {
                non_rep[n] = Ch;
                n++;
            }
            count = 0;
        }

        for (i = 0; i < Len; i++) {
            if (rep[i] != 0) {
                count++;
            }
        }

        char Z = arr[Len - 1];
        int A = 0;
        for (i = 0; i < Len; i++) {
            if (Z == rep[i]) {
                flag = 1;
            }
        }
        if (flag == 1) {
            for (i = 0; i < Len; i++) {
                if (non_rep[i] != 0) {
                    A++;
                }
            }
            non_rep[A - 1] = 0;
        }

        if (count == 0) {
            System.out.print("d = " + D + ", ");
            D--;
            int temp = Len - D;
            char X = arr[temp - 1];

            for (i = 0; i < Len; i++)
                System.out.print(arr[i]);
            System.out.println(X + "\n");
        }

        else {
            int C = 0;
            char Y;
            for (i = 0; i < Len; i++) {
                if (rep[i] != 0) {
                    Y = rep[i];
                    for (j = 0; j < Len; j++) {
                        if (arr[j] == Y) {
                            C++;
                        }
                    }
                    counted[i] = C;
                    C = 0;
                }
            }
            j = counted[0];
            i = 0;
            n = 0;
            while (i < j) {
                System.out.print(rep[0]);
                m = 0;
                while (m < D - 1) {
                    if (n < Len) {
                        System.out.print(non_rep[n]);
                        n++;
                    }
                    m++;
                }
                i++;
            }
        }

    }
}

public class Kshittiz201951084 extends Thread {
    public static void main(String[] args) {

        Scanner ob = new Scanner(System.in);
        boolean flag = true;

        String[] s = {"MAHI", "KSHITTIZ", "BHARDWAJ"};
        String S="201951084";

        int d1, d2, d3;
        int len = s[0].length();

        d1 = Integer.parseInt(S.substring(0, 1));
        d2 = Integer.parseInt(S.substring(4, 5));
        d3 = Integer.parseInt(S.substring(8, 9));
        int d = d1 + d2 + d3;
        String Name = s[0].substring(0, 4);

        while (d > len) {
            if (d % 2 != 0)
                d++;
            d = d / 2;
        }

        Thread T1 = new Thread(new rev_name(s));
        T1.start();
        Thread T2 = new Thread(new print_perm(Name));
        T2.start();
        Thread T3 = new Thread(new rearrange_name(s[0], d));
        T3.start();

    }
}