function [overlap_rate] = overlap_rate(vect1,vect2)

[~, intersection] = intersection_vect(vect2, vect1);
recouvrement = intersection(2) - intersection(1);
longueur_ref = max((vect1(2) - vect1(1)), (vect2(2) - vect2(1)));
overlap_rate = recouvrement/longueur_ref;


end