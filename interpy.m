function result=interpy(struct, range)

x = extractfield(struct,'x');
y = extractfield(struct, 'y');

linearCoefficients = polyfit(y, x, 1);
result = polyval(linearCoefficients, range);

end