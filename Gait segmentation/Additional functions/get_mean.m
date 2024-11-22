function  RB = get_mean(P1, P2, P3, P4)


RB_x = [P1(:,1) P2(:,1) P3(:,1) P4(:,1)];
RB_y = [P1(:,2) P2(:,2) P3(:,2) P4(:,2)];
RB_z = [P1(:,3) P2(:,3) P3(:,3) P4(:,3)];
RB_x = mean(RB_x')';
RB_y = mean(RB_y')';
RB_z = mean(RB_z')';

RB = [RB_x RB_y RB_z];